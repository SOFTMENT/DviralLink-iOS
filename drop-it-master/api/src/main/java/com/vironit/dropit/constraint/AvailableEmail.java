package com.vironit.dropit.constraint;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Documented
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = AvailableEmailValidator.class)
public @interface AvailableEmail {
    String message() default "Email already exists. Please enter another email.";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
