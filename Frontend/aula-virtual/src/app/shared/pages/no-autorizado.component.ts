import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-no-autorizado',
  imports: [CommonModule, RouterModule],
  template: `
    <div class="p-4 text-center">
      <h1 class="text-2xl font-bold text-red-600">Acceso denegado</h1>
      <p class="mb-4">No tienes permisos para acceder a esta sección.</p>
      <a routerLink="/login" class="text-blue-600 underline">Volver al inicio</a>
    </div>
  `
})
export class NoAutorizadoComponent {}
