package utez.edu.mx.ecommerceapi.shared.decorators.interfaces;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import utez.edu.mx.ecommerceapi.shared.decorators.validation.NullButNotBlankValidator;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = NullButNotBlankValidator.class)
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface NullButNotBlank {
    String message() default "El campo no puede contener solo espacios";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}