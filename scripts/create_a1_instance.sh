#!/bin/bash

export SUPPRESS_LABEL_WARNING=True

STACK_ID="ocid1.ormstack.oc1.iad.amaaaaaatmmaayiaajhm4bf7ady4wmckubznrk2dsqk33fnwlgqbzn4m6cua"
LOGFILE="oracle_automation_v3.log"
RETRY_WAIT=300  # 5 minutes between normal retries
RATE_LIMIT_WAIT=600  # 10 minutes after rate limit error

echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking dependencies..." | tee -a ${LOGFILE}

# Check and install jq if not present
if ! command -v jq &> /dev/null; then
    echo "Installing jq..." | tee -a ${LOGFILE}
    sudo apt-get update -qq
    sudo apt-get install -y jq
fi

# Check and install OCI CLI if not present
if ! command -v oci &> /dev/null; then
    echo "Installing OCI CLI..." | tee -a ${LOGFILE}
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
    
    # Add to PATH for current session
    export PATH="$HOME/bin:$PATH"
    
    # Check if OCI config exists
    if [ ! -f ~/.oci/config ]; then
        echo "ERROR: OCI CLI installed but ~/.oci/config not found!" | tee -a ${LOGFILE}
        echo "Please run 'oci setup config' to configure OCI CLI" | tee -a ${LOGFILE}
        exit 1
    fi
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Dependencies OK" | tee -a ${LOGFILE}
echo "$(date '+%Y-%m-%d %H:%M:%S') - Using Stack ID: ${STACK_ID}" | tee -a ${LOGFILE}
echo | tee -a ${LOGFILE}

function plan_job() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting PLAN job..." | tee -a ${LOGFILE}
    
    # Try to create job, capture output
    RESULT=$(oci resource-manager job create --stack-id ${STACK_ID} --operation PLAN --query "data.id" --raw-output 2>&1)
    
    # Check for rate limit error
    if echo "$RESULT" | grep -q "TooManyRequests"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Rate limit hit! Waiting ${RATE_LIMIT_WAIT} seconds..." | tee -a ${LOGFILE}
        sleep ${RATE_LIMIT_WAIT}
        return 2  # Special return code for rate limit
    fi
    
    # Check for other errors
    if echo "$RESULT" | grep -q "ServiceError\|Error"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error creating PLAN job: $RESULT" | tee -a ${LOGFILE}
        return 1
    fi
    
    JOB_ID="$RESULT"
    echo "Created 'PLAN' job with ID: '${JOB_ID}'" | tee -a ${LOGFILE}
    echo -n "Status for 'PLAN' job:" | tee -a ${LOGFILE}

    while true; do
        OSTATUS=${STATUS}
        JOB=$(oci resource-manager job get --job-id ${JOB_ID} 2>&1)
        
        # Check if JOB is valid JSON
        if ! echo "$JOB" | jq empty 2>/dev/null; then
            echo -n "." | tee -a ${LOGFILE}
            sleep 10
            continue
        fi
        
        STATUS=$(echo ${JOB} | jq -r '.data."lifecycle-state"')
        WAIT=10
        for i in $(seq 1 ${WAIT}); do
            if [ "${STATUS}" == "${OSTATUS}" ]; then
                echo -n "." | tee -a ${LOGFILE}
            else
                echo -n " ${STATUS}" | tee -a ${LOGFILE}
                break
            fi
            sleep 1
        done
        if [ "${STATUS}" == "SUCCEEDED" ]; then
            echo -e "\n" | tee -a ${LOGFILE}
            return 0
        elif [ "${STATUS}" == "FAILED" ]; then
            echo -e "\nThe 'PLAN' job failed." | tee -a ${LOGFILE}
            return 1
        fi
        sleep 5
    done
}

function apply_job() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting APPLY job..." | tee -a ${LOGFILE}
    
    # Try to create job, capture output
    RESULT=$(oci resource-manager job create --stack-id ${STACK_ID} --operation APPLY --apply-job-plan-resolution "{\"isAutoApproved\":true}" --query "data.id" --raw-output 2>&1)
    
    # Check for rate limit error
    if echo "$RESULT" | grep -q "TooManyRequests"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Rate limit hit! Waiting ${RATE_LIMIT_WAIT} seconds..." | tee -a ${LOGFILE}
        sleep ${RATE_LIMIT_WAIT}
        return 2  # Special return code for rate limit
    fi
    
    # Check for other errors
    if echo "$RESULT" | grep -q "ServiceError\|Error"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error creating APPLY job: $RESULT" | tee -a ${LOGFILE}
        return 1
    fi
    
    JOB_ID="$RESULT"
    echo "Created 'APPLY' job with ID: '${JOB_ID}'" | tee -a ${LOGFILE}
    echo -n "Status for 'APPLY' job:" | tee -a ${LOGFILE}

    while true; do
        OSTATUS=${STATUS}
        JOB=$(oci resource-manager job get --job-id ${JOB_ID} 2>&1)
        
        # Check if JOB is valid JSON
        if ! echo "$JOB" | jq empty 2>/dev/null; then
            echo -n "." | tee -a ${LOGFILE}
            sleep 10
            continue
        fi
        
        STATUS=$(echo ${JOB} | jq -r '.data."lifecycle-state"')
        WAIT=10
        for i in $(seq 1 ${WAIT}); do
            if [ "${STATUS}" == "${OSTATUS}" ]; then
                echo -n "." | tee -a ${LOGFILE}
            else
                echo -n " ${STATUS}" | tee -a ${LOGFILE}
                break
            fi
            sleep 1
        done
        if [ "${STATUS}" == "SUCCEEDED" ]; then
            echo -e "\n✅ SUCCESS! The 'APPLY' job succeeded!" | tee -a ${LOGFILE}
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Instance created successfully!" | tee -a ${LOGFILE}
            exit 0
        elif [ "${STATUS}" == "FAILED" ]; then
            echo -e "\nThe 'APPLY' job failed." | tee -a ${LOGFILE}
            ERROR_MSG=$(echo ${JOB} | jq -r '.data."failure-details".message')
            echo "Error: ${ERROR_MSG}" | tee -a ${LOGFILE}
            
            # Check if it's a capacity error
            if echo "${ERROR_MSG}" | grep -q "Out of capacity"; then
                echo "Capacity issue - will retry..." | tee -a ${LOGFILE}
            fi
            return 1
        fi
        sleep 5
    done
}

ATTEMPT=0
while true; do
    ATTEMPT=$((ATTEMPT + 1))
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Attempt #${ATTEMPT}" | tee -a ${LOGFILE}
    
    PLAN_RESULT=0
    plan_job
    PLAN_RESULT=$?
    
    if [ $PLAN_RESULT -eq 2 ]; then
        # Rate limit hit, already waited in function
        continue
    elif [ $PLAN_RESULT -ne 0 ]; then
        sleep ${RETRY_WAIT}
        continue
    fi
    
    APPLY_RESULT=0
    apply_job
    APPLY_RESULT=$?
    
    if [ $APPLY_RESULT -eq 2 ]; then
        # Rate limit hit, already waited in function
        continue
    elif [ $APPLY_RESULT -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Waiting ${RETRY_WAIT} seconds before retry..." | tee -a ${LOGFILE}
        sleep ${RETRY_WAIT}
    fi
done
