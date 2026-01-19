package com.payment.redis.config;

import io.lettuce.core.RedisClient;
import io.lettuce.core.api.StatefulRedisConnection;
import io.micronaut.context.annotation.Bean;
import io.micronaut.context.annotation.Factory;
import io.micronaut.context.annotation.Prototype;
import io.micronaut.context.annotation.Value;
import jakarta.inject.Singleton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Redis configuration and connection management
 */
@Factory
public class RedisConfig {
    private static final Logger log = LoggerFactory.getLogger(RedisConfig.class);

    @Value("${redis.uri:redis://localhost:6379}")
    private String redisUri;

    public RedisConfig() {
        log.info("🔧 Initializing Redis configuration");
    }

    /**
     * Create Redis client
     */
    @Singleton
    public RedisClient redisClient() {
        log.info("Creating Redis client with URI: {}", redisUri);
        return RedisClient.create(redisUri);
    }

    /**
     * Create Redis connection
     */
    @Singleton
    public StatefulRedisConnection<String, String> createRedisConnection(
            RedisClient client) {
        StatefulRedisConnection<String, String> connection = client.connect();
        log.info("✅ Redis connection established");
        return connection;
    }
}
