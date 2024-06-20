package com.vironit.dropit.constraint;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Constraint(validatedBy = LinkValidator.class)
public @interface Link {

    String message() default "Please share the links to music sources only.";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}