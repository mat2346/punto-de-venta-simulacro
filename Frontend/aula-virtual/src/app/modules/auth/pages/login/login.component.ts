import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SessionService } from '../../../../core/services/session.service';
import { Router } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-login',
  imports: [CommonModule, FormsModule],
  styleUrls: ['./login.component.scss'],
  templateUrl: './login.component.html'
})
export default class LoginComponent {
  codigo = '';
  password = '';
  error = '';
  verPassword: boolean = false;

  constructor(private session: SessionService, private router: Router) {}

  onLogin() {
    this.session.login(this.codigo, this.password).subscribe({
      next: () => {},
      error: err => {
        this.error = err.error?.detail || 'Código o contraseña incorrectos';
      }
    });
  }
}
