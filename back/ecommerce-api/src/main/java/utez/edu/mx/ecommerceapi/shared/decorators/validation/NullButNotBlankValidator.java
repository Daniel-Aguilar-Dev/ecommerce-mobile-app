package utez.edu.mx.ecommerceapi.shared.decorators.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import utez.edu.mx.ecommerceapi.shared.decorators.interfaces.NullButNotBlank;

public class NullButNotBlankValidator implements ConstraintValidator<NullButNotBlank, String> {
    @Override
    public boolean isValid(String value, ConstraintValidatorContext ctx) {
        return value == null || !value.isBlank();
    }
}
