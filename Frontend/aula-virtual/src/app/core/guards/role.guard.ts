import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { SessionService } from '../services/session.service';

export function roleGuard(allowedRoles: string[]): CanActivateFn {
  return () => {
    const session = inject(SessionService);
    const router = inject(Router);

    const rol = session.role?.toLowerCase();

    const allowed = allowedRoles.map(r => r.toLowerCase());

    if (session.isLoggedIn && rol && allowed.includes(rol)) {
      return true;
    }

    return router.createUrlTree(['/no-autorizado']);
  };
}
