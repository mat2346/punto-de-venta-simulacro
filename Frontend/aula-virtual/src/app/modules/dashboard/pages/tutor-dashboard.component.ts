import { Component, OnInit } from '@angular/core';
import { NgIf, NgFor, NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TutorService } from '../../../core/services/tutor.service';
import { SidebarComponent } from '../components/sidebar.component';
import { TutorChartsComponent } from '../components/tutor-charts.component';

interface Tab {
  id: string;
  label: string;
  icon: string;
  badge: string | null;
}

@Component({
  selector: 'app-tutor-dashboard',
  standalone: true,
  imports: [NgIf, NgFor, NgClass, FormsModule, SidebarComponent, TutorChartsComponent],
  template: `
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <app-sidebar class="w-64"></app-sidebar>

      <!-- Contenido principal -->
      <main class="flex-1 p-6 bg-gradient-to-b from-purple-100 to-purple-300 overflow-auto">

        <!-- Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-800 mb-2">Dashboard Tutor</h1>
          <p class="text-gray-600">Monitoreo y seguimiento del rendimiento estudiantil</p>
        </div>

        <!-- Selección de hijo -->
        <div *ngIf="estudiantes.length > 0" class="bg-white rounded-lg shadow p-4 mb-6">
          <label for="select-hijo" class="block mb-2 font-semibold text-gray-700">Selecciona a tu hijo:</label>
          <div class="flex items-center space-x-4">
            <select
              id="select-hijo"
              class="border border-gray-300 rounded-lg p-3 flex-1 max-w-md focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              [(ngModel)]="hijoSeleccionado"
              (change)="cargarDatosHijo()"
            >
              <option value="" disabled>Selecciona un estudiante</option>
              <option *ngFor="let estudiante of estudiantes" [value]="estudiante.id">
                {{ estudiante.nombre }} ({{ estudiante.codigo }})
              </option>
            </select>
            <div *ngIf="hijoDatos" class="text-sm text-gray-600">
              Curso: {{ hijoDatos.curso || 'N/A' }}
            </div>
          </div>
        </div>

        <!-- Loading -->
        <div *ngIf="cargando" class="flex justify-center items-center my-10">
          <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-purple-500"></div>
          <p class="ml-4 text-lg text-gray-600">Cargando información...</p>
        </div>

        <!-- Error -->
        <div *ngIf="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
          <p>{{ error }}</p>
        </div>

        <!-- Contenido con pestañas -->
        <div *ngIf="hijoSeleccionado && !cargando">
          
          <!-- Resumen rápido en tarjetas -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-blue-500">
              <p class="text-gray-600 text-sm font-medium">Promedio General</p>
              <p class="text-2xl font-bold text-blue-600">{{ hijoDatos?.promedio || 'N/A' }}</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-green-500">
              <p class="text-gray-600 text-sm font-medium">Asistencia</p>
              <p class="text-2xl font-bold text-green-600">{{ hijoDatos?.asistencia || 'N/A' }}%</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-yellow-500">
              <p class="text-gray-600 text-sm font-medium">Actividades</p>
              <p class="text-2xl font-bold text-yellow-600">{{ hijoActividades.length || 0 }}</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-purple-500">
              <p class="text-gray-600 text-sm font-medium">Materias</p>
              <p class="text-2xl font-bold text-purple-600">{{ hijoMaterias.length || 0 }}</p>
            </div>
          </div>

          <!-- Sistema de Pestañas -->
          <div class="bg-white rounded-lg shadow-lg">
            
            <!-- Navegación de pestañas -->
            <div class="border-b border-gray-200">
              <nav class="flex space-x-8 px-6" aria-label="Tabs">
                <button
                  *ngFor="let tab of tabs; trackBy: trackByTabId"
                  (click)="cambiarTab(tab.id)"
                  [class]="getTabClass(tab.id)"
                  class="py-4 px-1 font-medium text-sm transition-all duration-200 border-b-2 focus:outline-none">
                  <div class="flex items-center space-x-2">
                    <span [innerHTML]="tab.icon"></span>
                    <span>{{ tab.label }}</span>
                    <span *ngIf="tab.badge" class="bg-purple-100 text-purple-800 text-xs font-semibold px-2 py-0.5 rounded-full">
                      {{ tab.badge }}
                    </span>
                  </div>
                </button>
              </nav>
            </div>

            <!-- Contenido de las pestañas -->
            <div class="p-6">
              
              <!-- TAB 1: Resumen -->
              <div *ngIf="tabActual === 'resumen'" class="space-y-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Resumen General</h2>
                
                <!-- Información del estudiante -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-gray-700 mb-3">Información Personal</h3>
                    <div class="space-y-2">
                      <p><span class="font-medium text-gray-600">Nombre:</span> {{ estudianteSeleccionado?.nombre }}</p>
                      <p><span class="font-medium text-gray-600">Código:</span> {{ estudianteSeleccionado?.codigo }}</p>
                      <p><span class="font-medium text-gray-600">Curso:</span> {{ hijoDatos?.curso || 'N/A' }}</p>
                    </div>
                  </div>
                  
                  <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-gray-700 mb-3">Estado Académico</h3>
                    <div class="space-y-2">
                      <p><span class="font-medium text-gray-600">Estado:</span> 
                        <span class="px-2 py-1 rounded-full text-xs font-semibold" [ngClass]="{
                          'bg-green-100 text-green-800': hijoDatos?.promedio >= 60,
                          'bg-red-100 text-red-800': hijoDatos?.promedio < 60
                        }">
                          {{ hijoDatos?.promedio >= 60 ? 'Aprobando' : 'En Riesgo' }}
                        </span>
                      </p>
                      <p><span class="font-medium text-gray-600">Materias:</span> {{ hijoMaterias.length || 0 }}</p>
                      <p><span class="font-medium text-gray-600">Participación:</span> {{ hijoDatos?.participacion || 'N/A' }}%</p>
                    </div>
                  </div>
                </div>

                <!-- Materias actuales -->
                <div *ngIf="hijoMaterias.length">
                  <h3 class="text-lg font-semibold mb-4 text-gray-700">Materias Actuales</h3>
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div *ngFor="let materia of hijoMaterias" class="bg-white border rounded-lg p-4 shadow-sm">
                      <h4 class="font-bold text-lg text-gray-800">{{ materia.nombre }}</h4>
                      <p class="text-sm text-gray-600 mb-2">{{ materia.profesor }}</p>
                      <div class="flex justify-between items-center">
                        <span class="text-sm text-gray-500">Promedio:</span>
                        <span class="font-semibold text-lg" [ngClass]="{
                          'text-green-600': materia.promedio >= 80,
                          'text-yellow-600': materia.promedio >= 60 && materia.promedio < 80,
                          'text-red-600': materia.promedio < 60
                        }">{{ materia.promedio || 'N/A' }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- TAB 2: Rendimiento -->
              <div *ngIf="tabActual === 'rendimiento'">
                <app-tutor-charts [datosRendimiento]="datosRendimiento"></app-tutor-charts>
              </div>

              <!-- TAB 3: Actividades -->
              <div *ngIf="tabActual === 'actividades'" class="space-y-6">
                <div class="flex justify-between items-center">
                  <h2 class="text-2xl font-semibold text-gray-800">Actividades del Estudiante</h2>
                  <div class="text-sm text-gray-600">
                    Total: {{ hijoActividades.length || 0 }} actividades
                  </div>
                </div>
                
                <div *ngIf="hijoActividades.length; else noActividades" class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Materia</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Título</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nota</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <tr *ngFor="let actividad of hijoActividades; trackBy: trackByActividadId" class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {{ actividad.materia }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          <div class="text-sm font-medium text-gray-900">{{ actividad.titulo }}</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {{ formatearFecha(actividad.fecha) }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                                [ngClass]="{
                                  'bg-green-100 text-green-800': actividad.estado === 'Entregado',
                                  'bg-yellow-100 text-yellow-800': actividad.estado === 'Pendiente',
                                  'bg-red-100 text-red-800': actividad.estado === 'Vencido'
                                }">
                            {{ actividad.estado }}
                          </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          <span *ngIf="actividad.nota !== null && actividad.nota !== undefined" 
                                class="font-semibold"
                                [ngClass]="{
                                  'text-green-600': actividad.nota >= 80,
                                  'text-yellow-600': actividad.nota >= 60 && actividad.nota < 80,
                                  'text-red-600': actividad.nota < 60
                                }">
                            {{ actividad.nota }}
                          </span>
                          <span *ngIf="actividad.nota === null || actividad.nota === undefined" 
                                class="text-gray-400 italic">Sin calificar</span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <ng-template #noActividades>
                  <div class="text-center py-8">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path>
                    </svg>
                    <h3 class="mt-2 text-sm font-medium text-gray-900">No hay actividades</h3>
                    <p class="mt-1 text-sm text-gray-500">No se encontraron actividades para este estudiante.</p>
                  </div>
                </ng-template>
              </div>

              <!-- TAB 4: Asistencia -->
              <div *ngIf="tabActual === 'asistencia'" class="space-y-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Control de Asistencia</h2>
                
                <!-- Resumen de asistencia -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div class="bg-green-50 p-4 rounded-lg border-l-4 border-green-500">
                    <p class="text-green-700 font-medium">Días Presente</p>
                    <p class="text-2xl font-bold text-green-600">{{ datosAsistencia?.presente || 0 }}</p>
                  </div>
                  <div class="bg-red-50 p-4 rounded-lg border-l-4 border-red-500">
                    <p class="text-red-700 font-medium">Días Ausente</p>
                    <p class="text-2xl font-bold text-red-600">{{ datosAsistencia?.ausente || 0 }}</p>
                  </div>
                  <div class="bg-blue-50 p-4 rounded-lg border-l-4 border-blue-500">
                    <p class="text-blue-700 font-medium">Porcentaje</p>
                    <p class="text-2xl font-bold text-blue-600">{{ calcularPorcentajeAsistencia() }}%</p>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>

        <!-- Mensaje cuando no hay hijo seleccionado -->
        <div *ngIf="!hijoSeleccionado && !cargando" class="text-center py-12">
          <svg class="mx-auto h-16 w-16 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
          </svg>
          <h3 class="mt-2 text-lg font-medium text-gray-900">Selecciona un estudiante</h3>
          <p class="mt-1 text-gray-500">Elige un estudiante de la lista para ver su información detallada.</p>
        </div>

      </main>
    </div>
  `
})
export class TutorDashboardComponent implements OnInit {

  estudiantes: any[] = [];
  hijoSeleccionado: string = '';
  cargando = false;
  error = '';

  // Datos del hijo seleccionado
  hijoDatos: any = null;
  hijoMaterias: any[] = [];
  hijoActividades: any[] = [];
  datosRendimiento: any = {};
  datosAsistencia: any = {};

  // Sistema de pestañas
  tabActual = 'resumen';

  tabs: Tab[] = [
    {
      id: 'resumen',
      label: 'Resumen',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>',
      badge: null
    },
    {
      id: 'rendimiento',
      label: 'Rendimiento',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>',
      badge: null
    },
    {
      id: 'actividades',
      label: 'Actividades',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>',
      badge: null
    },
    {
      id: 'asistencia',
      label: 'Asistencia',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
      badge: null
    }
  ];

  constructor(private tutorService: TutorService) {}

  ngOnInit() {
    this.cargarEstudiantes();
  }

  get estudianteSeleccionado() {
    return this.estudiantes.find(e => e.id == this.hijoSeleccionado);
  }

  // Métodos del sistema de pestañas
  cambiarTab(tabId: string): void {
    this.tabActual = tabId;
  }

  getTabClass(tabId: string): string {
    const baseClass = 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300';
    const activeClass = 'border-purple-500 text-purple-600';
    
    return this.tabActual === tabId ? activeClass : baseClass;
  }

  // Métodos de tracking
  trackByTabId(index: number, tab: Tab): string {
    return tab.id;
  }

  trackByActividadId(index: number, actividad: any): any {
    return actividad.id || index;
  }

  // Método para formatear fechas
  formatearFecha(fechaISO: string): string {
    if (!fechaISO) return 'Sin fecha';
    
    try {
      const fecha = new Date(fechaISO);
      const dia = fecha.getDate().toString().padStart(2, '0');
      const mes = (fecha.getMonth() + 1).toString().padStart(2, '0');
      const año = fecha.getFullYear();
      return `${dia}/${mes}/${año}`;
    } catch (error) {
      return 'Fecha inválida';
    }
  }

  // Calcular porcentaje de asistencia
  calcularPorcentajeAsistencia(): number {
    const presente = this.datosAsistencia?.presente || 0;
    const ausente = this.datosAsistencia?.ausente || 0;
    const total = presente + ausente;
    
    if (total === 0) return 0;
    return Math.round((presente / total) * 100);
  }

  private cargarEstudiantes() {
    this.cargando = true;
    this.error = '';
    
    this.tutorService.getEstudiantes().subscribe({
      next: (data) => {
        this.estudiantes = data;
        if (data.length > 0) {
          this.hijoSeleccionado = data[0].id.toString();
          this.cargarDatosHijo();
        }
        this.cargando = false;
      },
      error: (err) => {
        console.error('Error cargando estudiantes:', err);
        this.error = 'Error al cargar la lista de estudiantes';
        this.cargando = false;
      }
    });
  }

  cargarDatosHijo() {
    if (!this.hijoSeleccionado) return;

    this.cargando = true;
    this.error = '';

    const estudianteId = parseInt(this.hijoSeleccionado);

    // Cargar resumen del hijo
    this.tutorService.getResumenHijo(estudianteId).subscribe({
      next: (data) => {
        this.hijoDatos = {
          promedio: data.promedio_general,
          asistencia: data.asistencia,
          participacion: data.participacion,
          curso: data.curso
        };
        
        this.hijoMaterias = data.materias || [];
        this.hijoActividades = data.actividades_recientes || [];

        // Cargar datos de rendimiento para las gráficas
        this.tutorService.getRendimientoDetallado(estudianteId).subscribe({
          next: (rendimientoData) => {
            this.datosRendimiento = rendimientoData;
            this.datosAsistencia = rendimientoData.asistencia || {};
            
            // Actualizar badges
            this.actualizarBadgesTabs();
            this.cargando = false;
          },
          error: (err) => {
            console.error('Error cargando rendimiento:', err);
            this.cargando = false;
          }
        });
      },
      error: (err) => {
        console.error('Error cargando datos del hijo:', err);
        this.error = 'Error al cargar información del estudiante';
        this.cargando = false;
      }
    });
  }

  private actualizarBadgesTabs(): void {
    const actividadesTab = this.tabs.find(t => t.id === 'actividades');
    if (actividadesTab) {
      actividadesTab.badge = this.hijoActividades.length.toString();
    }

    const asistenciaTab = this.tabs.find(t => t.id === 'asistencia');
    if (asistenciaTab) {
      asistenciaTab.badge = `${this.calcularPorcentajeAsistencia()}%`;
    }
  }
}
