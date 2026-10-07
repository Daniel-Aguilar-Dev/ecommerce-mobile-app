package utez.edu.mx.ecommerceapi.shared.audit;

import org.springframework.data.domain.AuditorAware;
import org.springframework.stereotype.Component;
import utez.edu.mx.ecommerceapi.shared.util.SecurityUtils;

import java.util.Optional;

@Component
public class AuditorAwareImpl implements AuditorAware<Long> {

    @Override
    public Optional<Long> getCurrentAuditor() {
        return SecurityUtils.usuarioActualIdOpcional();
    }
}
