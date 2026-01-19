package com.payment.redis.config;

import io.lettuce.core.RedisClient;
import io.lettuce.core.api.StatefulRedisConnection;
import jakarta.inject.Singleton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Redis configuration and connection management
 */
@Singleton
public class RedisConfig {
    private static final Logger log = LoggerFactory.getLogger(RedisConfig.class);

    public RedisConfig() {
        log.info("🔧 Initializing Redis configuration");
    }

    /**
     * Create Redis connection
     */
    public StatefulRedisConnection<String, String> createRedisConnection(
            RedisClient client) {
        StatefulRedisConnection<String, String> connection = client.connect();
        log.info("✅ Redis connection established");
        return connection;
    }
}
