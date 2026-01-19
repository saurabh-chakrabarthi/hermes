package com.payment.redis.health;

import io.lettuce.core.api.StatefulRedisConnection;
import io.micronaut.health.HealthStatus;
import io.micronaut.management.health.indicator.HealthIndicator;
import io.micronaut.management.health.indicator.HealthResult;
import jakarta.inject.Singleton;
import org.reactivestreams.Publisher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;

/**
 * Health check indicator for Redis connectivity
 */
@Singleton
public class RedisHealthIndicator implements HealthIndicator {
    private static final Logger log = LoggerFactory.getLogger(RedisHealthIndicator.class);
    private final StatefulRedisConnection<String, String> connection;

    public RedisHealthIndicator(StatefulRedisConnection<String, String> connection) {
        this.connection = connection;
    }

    @Override
    public Publisher<HealthResult> getResult() {
        return Mono.fromCallable(() -> {
            try {
                String pong = connection.sync().ping();
                log.info("✅ Redis health check: PASS");
                return HealthResult.builder("redis")
                    .status(HealthStatus.UP)
                    .details(java.util.Map.of(
                        "status", "connected",
                        "response", pong
                    ))
                    .build();
            } catch (Exception e) {
                log.error("❌ Redis health check: FAIL", e);
                return HealthResult.builder("redis")
                    .status(HealthStatus.DOWN)
                    .details(java.util.Map.of(
                        "status", "disconnected",
                        "error", e.getMessage()
                    ))
                    .build();
            }
        });
    }
}
