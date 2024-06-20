package com.vironit.dropit.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import lombok.Data;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
@Entity
@Table(name = "tokens")
public class Token {

	@Id
	private String key;

	@Column(name = "expiration_time")
	private LocalDateTime expirationTime;

	@Enumerated(EnumType.STRING)
	private TokenPurpose purpose;

	@OneToOne
	@JoinColumn(name = "user_id")
	private User user;
}