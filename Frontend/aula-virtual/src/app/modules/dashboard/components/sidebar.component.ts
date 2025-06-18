import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SessionService } from '../../../core/services/session.service';


@Component({
  standalone: true,
  selector: 'app-sidebar',
  imports: [CommonModule, RouterModule],
  template: `
    <aside class="w-64 h-screen bg-slate-900 text-white flex flex-col">
      <div class="text-xl font-bold p-4 border-b border-slate-700">Dashboard</div>
      <nav class="flex-1 px-4 py-6">
       
        <a routerLink="/cursos" class="block py-2 px-3 rounded hover:bg-slate-700">📊 Dashboard</a>
       
      </nav>
      <div class="p-4 border-t border-slate-700">
        <button (click)="cerrarSesion()" class="w-full text-left py-2 px-3 hover:bg-red-700 rounded">
    🔓 Cerrar sesión
        </button>
      </div>
    </aside>
  `
})
export class SidebarComponent {
  constructor(private session: SessionService) {}

  cerrarSesion() {
    const confirmar = confirm('¿Estás seguro de que deseas cerrar sesión?');
    if (confirmar) {
      console.log('✅ Cerrando sesión...');
      this.session.logout();
    } else {
      console.log('❎ Cancelado por el usuario.');
    }
  }
}