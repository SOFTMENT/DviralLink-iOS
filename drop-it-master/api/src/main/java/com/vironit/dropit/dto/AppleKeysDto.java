package com.vironit.dropit.dto;

import lombok.Data;
import lombok.experimental.Accessors;

import java.util.List;
import java.util.Map;

@Data
@Accessors(chain = true)
public class AppleKeysDto {

    private List<Map<String, String>> keys;
}
