import { Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { environment } from '../../../environments/environment';
export interface Usuario {
  id: number;
  nombre: string;
  codigo: string;
  rol: { nombre: 'admin' | 'profesor' | 'estudiante' | 'tutor' };
  [key: string]: any;
}

@Injectable({ providedIn: 'root' })
export class SessionService {
  private usuario = signal<Usuario | null>(null);
  private readonly storageKey = 'usuario';

  constructor(private router: Router, private http: HttpClient) {
    if (typeof localStorage !== 'undefined') {
      const raw = localStorage.getItem(this.storageKey);
      try {
        const parsed = raw ? JSON.parse(raw) : null;
        this.usuario.set(parsed);
      } catch {
        localStorage.removeItem(this.storageKey);
        this.usuario.set(null);
      }
    }
  }

  login(codigo: string, password: string) {
    return this.http.post<{ access: string; refresh: string; usuario: Usuario }>(
      environment.apiUrl+'api/login/',
      { codigo, password }
    ).pipe(
      tap((resp) => {
        // Guarda los tokens JWT
        localStorage.setItem('access_token', resp.access);
        localStorage.setItem('refresh_token', resp.refresh);

        // Guarda el usuario y redirige por rol
        console.log('Rol recibido:', resp.usuario.rol?.nombre); 
        this.setUsuario(resp.usuario);
        this.redireccionarPorRol(resp.usuario.rol?.nombre);
      })
    );
  }

  private redireccionarPorRol(rol: string) {
    switch (rol) {
      case 'admin':
        this.router.navigate(['/admin']);
        break;
      case 'profesor':
        this.router.navigate(['/profesor']);
        break;
      case 'estudiante':
        this.router.navigate(['/mi-rendimiento']);
        break;
      case 'tutor':
        this.router.navigate(['/mi-hijo']);
        break;
      default:
        this.router.navigate(['/']);
    }
  }

  setUsuario(usuario: Usuario) {
    this.usuario.set(usuario);
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem(this.storageKey, JSON.stringify(usuario));
    }
  }

  logout() {
    this.usuario.set(null);
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem(this.storageKey);
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
    }
    this.router.navigate(['/login']);
  }

    get usuarioSignal() {
    return this.usuario;
  }

  get currentUser() {
    return this.usuario();
  }

  get role() {
    return this.usuario()?.rol?.nombre;
  }

  get isLoggedIn() {
    return !!this.usuario();
  }
}
