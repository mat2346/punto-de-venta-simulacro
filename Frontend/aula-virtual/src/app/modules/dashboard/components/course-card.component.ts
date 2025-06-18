import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-course-card',
  imports: [CommonModule],
  template: `
    <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
      <h3 class="text-lg font-semibold mb-2 text-gray-800">{{curso}}</h3>
      <p class="text-gray-600 mb-4">Gestiona tu materia y estudiantes</p>
      
      <div class="space-y-2">
        <button 
          (click)="detalleClick.emit(detalleMateriaId)"
          class="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 transition-colors">
          📊 Ver Detalles
        </button>
        
        <button 
          (click)="enviarNotificacionRapida()"
          class="w-full bg-green-600 text-white py-2 px-4 rounded hover:bg-green-700 transition-colors">
          📱 Notificar Estudiantes
        </button>
      </div>
    </div>
  `
})
export class CourseCardComponent {
  @Input() curso!: string;
  @Input() detalleMateriaId!: number;
  @Output() detalleClick = new EventEmitter<number>();

  constructor(private router: Router) {}

  enviarNotificacionRapida() {
    // Navegar al dashboard con la tab de notificaciones activa y la materia preseleccionada
    this.router.navigate(['/profesor/dashboard'], { 
      queryParams: { 
        tab: 'notificaciones', 
        materia: this.detalleMateriaId 
      } 
    });
  }
}
