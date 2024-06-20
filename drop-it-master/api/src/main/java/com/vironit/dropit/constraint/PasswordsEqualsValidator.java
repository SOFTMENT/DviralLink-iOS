package com.vironit.dropit.constraint;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import java.lang.reflect.Method;

public class PasswordsEqualsValidator implements ConstraintValidator<PasswordsEquals, Object> {

    private String field;
    private String equalsTo;
    private String message = PasswordsEquals.MESSAGE;

    public void initialize(PasswordsEquals constraintAnnotation) {
        this.message = constraintAnnotation.message();
        this.field = constraintAnnotation.field();
        this.equalsTo = constraintAnnotation.equalsTo();
    }

    public boolean isValid(Object value, ConstraintValidatorContext context) {
        try {
            final Object fieldObject = getProperty(value, field, null);
            final Object equalsToObject = getProperty(value, equalsTo, null);

            if (fieldObject == null && equalsToObject == null) {
                return true;
            }

            boolean matches = (fieldObject != null)
                    && fieldObject.equals(equalsToObject);

            if (!matches) {
                String msg = this.message;
                if (this.message == null
                        || "".equals(this.message)
                        || PasswordsEquals.MESSAGE.equals(this.message)) {
                    msg = "Password doesn't match";
                }
                context.disableDefaultConstraintViolation();
                context.buildConstraintViolationWithTemplate(msg)
                        .addNode(equalsTo).addConstraintViolation();
            }

            return matches;
        } catch (final Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    private Object getProperty(Object value, String fieldName,
                               Object defaultValue) {
        Class<?> clazz = value.getClass();
        String methodName = "get" + Character.toUpperCase(fieldName.charAt(0))
                + fieldName.substring(1);
        try {
            Method method = clazz.getDeclaredMethod(methodName, new Class[0]);
            return method.invoke(value);
        } catch (Exception e) {
        }
        return defaultValue;
    }
}