/*
 * Copyright 2016-present Pnoker All Rights Reserved
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      https://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.github.pnoker.common.utils;

import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * Redis 操作工具类
 *
 * @author pnoker
 * @since 2022.1.0
 */
@Slf4j
@Component
@SuppressWarnings({"rawtypes", "unchecked"})
public class RedisUtil {

    //TODO 这个泛型不知道好使不，前检查一下 RedisTemplateConfig
    @Resource
    private RedisTemplate redisTemplate;

    /**
     * 添加 Key 缓存
     *
     * @param key   String key
     * @param value Object
     * @param <T>   Value Type
     */
    public <T> void setKey(String key, final T value) {
        redisTemplate.opsForValue().set(key, value);
    }

    /**
     * 添加 Key 缓存,并设置失效时间
     *
     * @param key   String key
     * @param value Object
     * @param time  Time
     * @param unit  TimeUnit
     * @param <T>   Value Type
     */
    public <T> void setKey(String key, final T value, long time, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, time, unit);
    }

    /**
     * 批量添加 Key 缓存
     *
     * @param valuesMap Map String:Object
     */
    public <T> void setKey(Map<String, T> valuesMap) {
        redisTemplate.opsForValue().multiSet(valuesMap);
    }

    /**
     * 批量添加 Key 缓存,并设置失效时间
     *
     * @param valueMap     Map String:Object
     * @param expireMillis Map String:Long
     */
    public <T> void setKey(Map<String, T> valueMap, Map<String, Long> expireMillis) {
        redisTemplate.opsForValue().multiSet(valueMap);
        setExpire(expireMillis);
    }

    /**
     * 获取 Key 缓存
     *
     * @param key String key
     * @param <T> T
     * @return T
     */
    public <T> T getKey(final String key) {
        ValueOperations<String, T> operations = redisTemplate.opsForValue();
        return operations.get(key);
    }

    /**
     * 批量获取 Key 缓存值
     *
     * @param keys String key array
     * @param <T>  T
     * @return T Array
     */
    public <T> List<T> getKey(List<String> keys) {
        ValueOperations<String, T> operations = redisTemplate.opsForValue();
        return operations.multiGet(keys);
    }

    /**
     * 判断 Key 是否存在
     *
     * @param key String key
     * @return boolean
     */
    public boolean hasKey(String key) {
        Boolean hasKey = redisTemplate.hasKey(key);
        return Boolean.TRUE.equals(hasKey);
    }

    /**
     * 批量获取 Key 缓存
     *
     * @param pattern Key pattern
     * @return Key Set
     */
    public Set<String> getKeys(final String pattern) {
        return redisTemplate.keys(pattern);
    }

    /**
     * 删除 Key 缓存
     *
     * @param key Key
     */
    public void deleteKey(String key) {
        redisTemplate.delete(key);
    }

    /**
     * 批量删除 Key 缓存
     *
     * @param keys Key Array
     */
    public void deleteKey(List<String> keys) {
        redisTemplate.delete(keys);
    }

    /**
     * 指定键值失效时间
     *
     * @param key  String key
     * @param time Time
     * @param unit TimeUnit
     */
    public void setExpire(String key, long time, TimeUnit unit) {
        if (time > 0) {
            redisTemplate.expire(key, time, unit);
        }
    }

    /**
     * 批量指定键值失效时间
     *
     * @param expireMillis Map String:Long
     */
    public void setExpire(Map<String, Long> expireMillis) {
        if (null != expireMillis && expireMillis.size() > 0) {
            StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();
            redisTemplate.execute((RedisCallback<Object>) connection -> {
                expireMillis.forEach((key, expire) -> {
                    byte[] serialize = stringRedisSerializer.serialize(key);
                    if (null != serialize) {
                        connection.pExpire(serialize, expire);
                    }
                });
                return null;
            });
        }
    }

    /**
     * 指定键值在指定时间失效
     *
     * @param key  String key
     * @param date Date
     */
    public void setExpireAt(String key, Date date) {
        Date current = new Date();
        if (date.getTime() >= current.getTime()) {
            redisTemplate.expireAt(key, date);
        }
    }

    /**
     * 获取 Key 失效时间
     *
     * @param key  String key
     * @param unit TimeUnit
     * @return 剩余失效时长
     */
    public long getExpire(String key, TimeUnit unit) {
        return redisTemplate.getExpire(key, unit);
    }

}
