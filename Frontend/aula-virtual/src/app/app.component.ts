import { Component, effect } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SessionService } from './core/services/session.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  constructor(
    private session: SessionService,
    private router: Router
  ) {
    // Escucha cambios en la señal
    effect(() => {
      const user = this.session.usuarioSignal(); 
      if (!user) {
        console.log('🔄 Usuario desconectado → redirigiendo a /login');
        this.router.navigate(['/login']);
      }
    });
  }
}
