import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { SessionService } from '../services/session.service';

export const authGuard: CanActivateFn = () => {
  const session = inject(SessionService);
  const router = inject(Router);

  return session.isLoggedIn || router.createUrlTree(['/login']);
};
