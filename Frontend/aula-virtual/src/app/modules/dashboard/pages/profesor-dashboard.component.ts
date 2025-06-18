import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from '../components/sidebar.component';
import { CourseCardComponent } from '../components/course-card.component';
import { NotificacionesComponent } from '../components/notificaciones.component';
import { ProfesorService } from '../../../core/services/profesor.sevice';
import { Router, ActivatedRoute } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-profesor-dashboard',
  imports: [CommonModule, SidebarComponent, CourseCardComponent, NotificacionesComponent],
  template: `
    <div class="flex min-h-screen bg-gray-50">
      <app-sidebar></app-sidebar>
      <div class="flex-1 p-6">
        <div class="max-w-7xl mx-auto">
          <h1 class="text-3xl font-bold mb-6 text-gray-800">👨‍🏫 Dashboard del Profesor</h1>

          <!-- Tabs de navegación -->
          <div class="mb-6 border-b border-gray-200">
            <nav class="-mb-px flex space-x-8">
              <button 
                (click)="activeTab = 'materias'"
                [class]="activeTab === 'materias' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                class="whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm">
                📚 Mis Materias
              </button>
              <button 
                (click)="activeTab = 'notificaciones'"
                [class]="activeTab === 'notificaciones' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                class="whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm">
                📱 Notificaciones
              </button>
            </nav>
          </div>

          <!-- Contenido de las tabs -->
          <div [ngSwitch]="activeTab">
            
            <!-- Tab de Materias -->
            <div *ngSwitchCase="'materias'">
              <div class="mb-6 flex gap-4">
                <button class="bg-blue-700 text-white px-6 py-2 rounded-lg hover:bg-blue-800 transition-colors">
                  ✏️ Nueva Tarea
                </button>
                <button class="border border-blue-700 text-blue-700 px-6 py-2 rounded-lg hover:bg-blue-50 transition-colors">
                  👥 Gestionar Alumnos
                </button>
                <button 
                  (click)="activeTab = 'notificaciones'"
                  class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors">
                  📤 Enviar Notificación
                </button>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <app-course-card
                  *ngFor="let m of materias"
                  [curso]="m.materia + ' - ' + m.curso + ' ' + m.paralelo"
                  [detalleMateriaId]="m.detalle_id"
                  (detalleClick)="irADetalle($event)">
                </app-course-card>
              </div>

              <div *ngIf="materias.length === 0" class="text-center py-12">
                <div class="text-gray-400 text-6xl mb-4">📚</div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">No hay materias asignadas</h3>
                <p class="text-gray-500">Contacta al administrador para que te asigne materias.</p>
              </div>
            </div>

            <!-- Tab de Notificaciones -->
            <div *ngSwitchCase="'notificaciones'">
              <app-notificaciones [materiaPreseleccionada]="materiaPreseleccionada"></app-notificaciones>
            </div>

          </div>
        </div>
      </div>
    </div>
  `
})
export class ProfesorDashboardComponent implements OnInit {
  materias: any[] = [];
  activeTab: 'materias' | 'notificaciones' = 'materias';
  materiaPreseleccionada: string = '';

  constructor(
    private profesorService: ProfesorService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    // Cargar materias
    this.profesorService.getMateriasConCurso().subscribe(
      data => {
        console.log('Materias recibidas:', data);
        this.materias = data;
      },
      error => {
        console.error('Error cargando materias:', error);
      }
    );

    // Manejar parámetros de query
    this.route.queryParams.subscribe(params => {
      if (params['tab'] === 'notificaciones') {
        this.activeTab = 'notificaciones';
      }
      if (params['materia']) {
        this.materiaPreseleccionada = params['materia'];
      }
    });
  }

  irADetalle(id: number) {
    this.router.navigate(['/profesor/materia', id]);
  }
}
