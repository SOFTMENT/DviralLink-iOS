package com.vironit.dropit.config;

import static java.time.LocalDateTime.now;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.springframework.beans.factory.ObjectFactory;
import org.springframework.beans.factory.config.Scope;

public class PeriodicalScopeConfigurer implements Scope {

	Map<String, Pair<LocalDateTime, Object>> map = new HashMap<>();

	@Override
	public Object get(String name, ObjectFactory<?> objectFactory) {
		if (map.containsKey(name)) {
			Pair<LocalDateTime, Object> pair = map.get(name);
			Duration duration = Duration.between(pair.getKey(), now());
			if (duration.getSeconds() > 60 * 60) {
				map.put(name, new ImmutablePair<>(now(), objectFactory.getObject()));
			}
		} else {
			map.put(name, new ImmutablePair<>(now(), objectFactory.getObject()));
		}

		return map.get(name).getValue();
	}

	@Override
	public Object remove(String s) {
		return null;
	}

	@Override
	public void registerDestructionCallback(String s, Runnable runnable) {

	}

	@Override
	public Object resolveContextualObject(String s) {
		return null;
	}

	@Override
	public String getConversationId() {
		return null;
	}
}
