import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { NgFor, NgClass, NgIf, SlicePipe } from '@angular/common';
import { AlumnoService } from '../../../core/services/alumno.service';
import { SidebarComponent } from '../components/sidebar.component';
import { AsistenciaChartComponent } from '../components/asistencia-chart.component';
import { NotasGraficoComponent } from './notas-grafico.component';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
// 👈 Definir interfaces para mejor tipado
interface Tab {
  id: string;
  label: string;
  icon: string;
  badge: string | null; // 👈 Permitir string o null
}

@Component({
  selector: 'app-alumno-materia-detalle',
  standalone: true,
  imports: [
    NgFor, NgClass, NgIf, SidebarComponent, AsistenciaChartComponent, SlicePipe,
    NotasGraficoComponent // 👈 agrega aquí
  ],
  template: `
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <app-sidebar class="w-64"></app-sidebar>

      <!-- Contenido principal -->
      <main class="flex-1 p-6 bg-gradient-to-b from-blue-100 to-blue-300 overflow-auto">
        
        <!-- Header con botón de regreso -->
        <div class="flex items-center justify-between mb-6">
          <div>
            <button 
              (click)="volver()" 
              class="flex items-center text-blue-600 hover:text-blue-800 mb-2 transition-colors">
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
              </svg>
              Volver al Dashboard
            </button>
            <h1 class="text-3xl font-bold text-gray-800">{{ detalleMateria.nombre || 'Cargando...' }}</h1>
            <p class="text-gray-600">Profesor: {{ detalleMateria.profesor }}</p>
          </div>
        </div>

        <!-- Loading -->
        <div *ngIf="cargando" class="flex justify-center items-center my-10">
          <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-blue-500"></div>
          <p class="ml-4 text-lg text-gray-600">Cargando información...</p>
        </div>

        <!-- Error -->
        <div *ngIf="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
          <div class="flex items-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
            </svg>
            <p>{{ error }}</p>
          </div>
        </div>

        <!-- Contenido principal con pestañas -->
        <div *ngIf="!cargando && !error">
          
          <!-- Resumen rápido en tarjetas -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-blue-500">
              <p class="text-gray-600 text-sm font-medium">Promedio General</p>
              <p class="text-2xl font-bold text-blue-600">{{ detalleMateria.promedio }}</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-green-500">
              <p class="text-gray-600 text-sm font-medium">Asistencia</p>
              <p class="text-2xl font-bold text-green-600">{{ asistencia.porcentaje }}%</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-purple-500">
              <p class="text-gray-600 text-sm font-medium">Actividades</p>
              <p class="text-2xl font-bold text-purple-600">{{ actividades.length }}</p>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md border-l-4 border-yellow-500">
              <p class="text-gray-600 text-sm font-medium">Clases Totales</p>
              <p class="text-2xl font-bold text-yellow-600">{{ asistencia.total_clases }}</p>
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
                    <span *ngIf="tab.badge" class="bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-0.5 rounded-full">
                      {{ tab.badge }}
                    </span>
                  </div>
                </button>
              </nav>
            </div>

            <!-- Contenido de las pestañas -->
            <div class="p-6">
              
              <!-- TAB 1: Información General -->
              <div *ngIf="tabActual === 'info'" class="space-y-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Información General</h2>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-gray-700 mb-3">Detalles de la Materia</h3>
                    <div class="space-y-2">
                      <p><span class="font-medium text-gray-600">Materia:</span> {{ detalleMateria.nombre }}</p>
                      <p><span class="font-medium text-gray-600">Profesor:</span> {{ detalleMateria.profesor }}</p>
                      <p><span class="font-medium text-gray-600">Curso:</span> {{ detalleMateria.curso }}</p>
                    </div>
                  </div>
                  
                  <div class="bg-gray-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-gray-700 mb-3">Rendimiento Actual</h3>
                    <div class="space-y-2">
                      <p><span class="font-medium text-gray-600">Promedio:</span> 
                        <span class="text-lg font-bold" [ngClass]="{
                          'text-green-600': detalleMateria.promedio >= 80,
                          'text-yellow-600': detalleMateria.promedio >= 60 && detalleMateria.promedio < 80,
                          'text-red-600': detalleMateria.promedio < 60
                        }">{{ detalleMateria.promedio }}</span>
                      </p>
                      <p><span class="font-medium text-gray-600">Estado:</span> 
                        <span class="px-2 py-1 rounded-full text-xs font-semibold" [ngClass]="{
                          'bg-green-100 text-green-800': detalleMateria.promedio >= 60,
                          'bg-red-100 text-red-800': detalleMateria.promedio < 60
                        }">
                          {{ detalleMateria.promedio >= 60 ? 'Aprobando' : 'En Riesgo' }}
                        </span>
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- TAB 2: Gráficos de Asistencia -->
              <div *ngIf="tabActual === 'asistencia'">
                <app-asistencia-chart 
                  [datosAsistencia]="asistencia"
                  [titulo]="'Análisis de Asistencia - ' + detalleMateria.nombre">
                </app-asistencia-chart>
              </div>

              <!-- TAB 3: Actividades -->
              <div *ngIf="tabActual === 'actividades'" class="space-y-6">
                <div class="flex justify-between items-center">
                  <h2 class="text-2xl font-semibold text-gray-800">Actividades Asignadas</h2>
                  <div class="text-sm text-gray-600">
                    Total: {{ actividades.length }} actividades
                  </div>
                </div>
                
                <div class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Título</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Descripción</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nota</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <tr *ngFor="let actividad of actividades; trackBy: trackByActividadId" class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap">
                          <div class="text-sm font-medium text-gray-900">{{ actividad.titulo || 'Sin título' }}</div>
                        </td>
                        <td class="px-6 py-4">
                          <div class="text-sm text-gray-500">
                            {{ actividad.descripcion || 'Sin descripción' }}
                          </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                            {{ actividad.tipo || actividad.dimension || 'No especificado' }}
                          </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {{ formatearFecha(actividad.fecha_entrega || actividad.fecha_creacion) }}
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
              </div>

              <!-- TAB 4: Notas - Formato Excel -->
              <div *ngIf="tabActual === 'notas'" class="space-y-6">
                <div class="flex justify-between items-center mb-4">
                  <h2 class="text-2xl font-semibold text-gray-800">Notas por Dimensión</h2>
                  <div class="text-sm text-gray-600">
                    Total: {{ getActividadesEntregadas().length }} actividades calificadas
                  </div>
                </div>

                <!-- Leyenda de dimensiones -->
                <div class="flex flex-wrap gap-3 mb-4">
                  <div class="flex items-center px-3 py-1 rounded-full bg-purple-50 text-purple-700 text-sm">
                    <div class="h-3 w-3 rounded-full bg-purple-500 mr-2"></div>
                    Ser
                  </div>
                  <div class="flex items-center px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-sm">
                    <div class="h-3 w-3 rounded-full bg-blue-500 mr-2"></div>
                    Saber
                  </div>
                  <div class="flex items-center px-3 py-1 rounded-full bg-yellow-50 text-yellow-700 text-sm">
                    <div class="h-3 w-3 rounded-full bg-yellow-500 mr-2"></div>
                    Hacer
                  </div>
                  <div class="flex items-center px-3 py-1 rounded-full bg-green-50 text-green-700 text-sm">
                    <div class="h-3 w-3 rounded-full bg-green-500 mr-2"></div>
                    Decidir
                  </div>
                </div>
                
                <!-- Vista Excel de actividades entregadas -->
                <div class="bg-white rounded-lg shadow-md overflow-hidden">
                  <!-- Encabezado -->
                  <div class="bg-gray-50 p-4 border-b border-gray-200">
                    <h3 class="font-semibold text-gray-700">Reporte de Calificaciones</h3>
                  </div>
                  
                  <!-- Sin actividades entregadas -->
                  <div *ngIf="getActividadesEntregadas().length === 0" class="p-8 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    <h3 class="mt-2 text-sm font-medium text-gray-900">No hay actividades calificadas</h3>
                    <p class="mt-1 text-sm text-gray-500">No hay actividades con estado "Entregado" para mostrar.</p>
                  </div>
                  
                  <!-- Tabla estilo Excel -->
                  <div *ngIf="getActividadesEntregadas().length > 0" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                      <thead class="bg-gray-50">
                        <tr>
                          <!-- Primera columna para los títulos de actividades -->
                          <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Actividad
                          </th>
                          
                          <!-- Columnas para cada dimensión -->
                          <th class="px-4 py-3 text-center text-xs font-medium text-purple-500 uppercase tracking-wider w-28 bg-purple-50">
                            Ser
                          </th>
                          <th class="px-4 py-3 text-center text-xs font-medium text-blue-500 uppercase tracking-wider w-28 bg-blue-50">
                            Saber
                          </th>
                          <th class="px-4 py-3 text-center text-xs font-medium text-yellow-500 uppercase tracking-wider w-28 bg-yellow-50">
                            Hacer
                          </th>
                          <th class="px-4 py-3 text-center text-xs font-medium text-green-500 uppercase tracking-wider w-28 bg-green-50">
                            Decidir
                          </th>
                          
                          <!-- Columna final para fecha -->
                          <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider w-28">
                            Fecha
                          </th>
                        </tr>
                      </thead>
                      <tbody class="bg-white divide-y divide-gray-200">
                        <!-- Filas para cada actividad entregada -->
                        <tr *ngFor="let actividad of getActividadesEntregadas(); trackBy: trackByActividadId" 
                            class="hover:bg-gray-50 transition-colors">
                          
                          <!-- Nombre de la actividad -->
                          <td class="px-4 py-3 whitespace-nowrap">
                            <div class="text-sm font-medium text-gray-900">{{ actividad.titulo }}</div>
                            <div class="text-sm text-gray-500" *ngIf="actividad.descripcion">
                              {{ actividad.descripcion | slice:0:50 }}{{ actividad.descripcion.length > 50 ? '...' : '' }}
                            </div>
                          </td>
                          
                          <!-- Celdas para cada dimensión -->
                          <td class="px-4 py-3 text-center" [ngClass]="{'bg-purple-50': actividad.dimension === 'ser'}">
                            <span *ngIf="actividad.dimension === 'ser'" 
                              class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                              [ngClass]="{
                                'bg-green-100 text-green-800': actividad.nota >= 80,
                                'bg-blue-100 text-blue-800': actividad.nota >= 70 && actividad.nota < 80,
                                'bg-yellow-100 text-yellow-800': actividad.nota >= 60 && actividad.nota < 70,
                                'bg-red-100 text-red-800': actividad.nota < 60
                              }">
                              {{ actividad.nota }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center" [ngClass]="{'bg-blue-50': actividad.dimension === 'saber'}">
                            <span *ngIf="actividad.dimension === 'saber'" 
                              class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                              [ngClass]="{
                                'bg-green-100 text-green-800': actividad.nota >= 80,
                                'bg-blue-100 text-blue-800': actividad.nota >= 70 && actividad.nota < 80,
                                'bg-yellow-100 text-yellow-800': actividad.nota >= 60 && actividad.nota < 70,
                                'bg-red-100 text-red-800': actividad.nota < 60
                              }">
                              {{ actividad.nota }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center" [ngClass]="{'bg-yellow-50': actividad.dimension === 'hacer'}">
                            <span *ngIf="actividad.dimension === 'hacer'" 
                              class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                              [ngClass]="{
                                'bg-green-100 text-green-800': actividad.nota >= 80,
                                'bg-blue-100 text-blue-800': actividad.nota >= 70 && actividad.nota < 80,
                                'bg-yellow-100 text-yellow-800': actividad.nota >= 60 && actividad.nota < 70,
                                'bg-red-100 text-red-800': actividad.nota < 60
                              }">
                              {{ actividad.nota }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center" [ngClass]="{'bg-green-50': actividad.dimension === 'decidir'}">
                            <span *ngIf="actividad.dimension === 'decidir'" 
                              class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                              [ngClass]="{
                                'bg-green-100 text-green-800': actividad.nota >= 80,
                                'bg-blue-100 text-blue-800': actividad.nota >= 70 && actividad.nota < 80,
                                'bg-yellow-100 text-yellow-800': actividad.nota >= 60 && actividad.nota < 70,
                                'bg-red-100 text-red-800': actividad.nota < 60
                              }">
                              {{ actividad.nota }}
                            </span>
                          </td>
                          
                          <!-- Fecha de la actividad -->
                          <td class="px-4 py-3 text-center text-sm text-gray-500">
                            {{ formatearFecha(actividad.fecha_entrega || actividad.fecha_creacion) }}
                          </td>
                        </tr>
                        
                        <!-- NUEVA FILA: Asistencia (se coloca antes de los promedios) -->
                        <tr class="bg-gray-50 hover:bg-gray-100 transition-colors">
                          <td class="px-4 py-3 text-sm text-gray-700 font-medium">
                            Asistencia
                          </td>
                          <td class="px-4 py-3 text-center bg-purple-50">
                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                                  [ngClass]="{
                                    'bg-green-100 text-green-800': calcularNotaAsistencia() >= 80,
                                    'bg-blue-100 text-blue-800': calcularNotaAsistencia() >= 70 && calcularNotaAsistencia() < 80,
                                    'bg-yellow-100 text-yellow-800': calcularNotaAsistencia() >= 60 && calcularNotaAsistencia() < 70,
                                    'bg-red-100 text-red-800': calcularNotaAsistencia() < 60
                                  }">
                              {{ calcularNotaAsistencia() }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center"></td>
                          <td class="px-4 py-3 text-center"></td>
                          <td class="px-4 py-3 text-center"></td>                          <td class="px-4 py-3 text-center text-sm text-gray-500">
                            {{ formatearFecha(fechaActual) }}
                          </td>
                        </tr>
                        
                        <!-- Fila de promedios -->
                        <tr class="bg-gray-50 font-medium">
                          <td class="px-4 py-3 text-sm text-gray-700">
                            Promedio por dimensión
                          </td>
                          <td class="px-4 py-3 text-center">
                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-purple-100 text-purple-800">
                              {{ calcularPromedioPorDimension('ser', true) }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center">
                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                              {{ calcularPromedioPorDimension('saber') }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center">
                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                              {{ calcularPromedioPorDimension('hacer') }}
                            </span>
                          </td>
                          <td class="px-4 py-3 text-center">
                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                              {{ calcularPromedioPorDimension('decidir') }}
                            </span>
                          </td>
                          
                        </tr>
                      </tbody>
                    </table>
                  </div>

                            <!-- Predicción de nota final -->
                  <div class="mt-8 bg-blue-50 rounded-lg p-4 flex items-center gap-4">
                    <button (click)="predecirNotaFinal()" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded font-semibold transition"
                            [disabled]="cargandoPrediccion">
                      Predecir Nota Final
                    </button>
                    <span *ngIf="cargandoPrediccion" class="text-blue-700">Calculando predicción...</span>
                    <span *ngIf="prediccionNota && !cargandoPrediccion" class="text-blue-900 font-bold">
                      Predicción de Nota: {{ prediccionNota }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- TAB 5: Análisis (sin cambios) -->
              <div *ngIf="tabActual === 'analisis'" class="space-y-6">
                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Análisis Predictivo</h2>
                <div class="bg-purple-50 border-l-4 border-purple-400 p-4 rounded">
                  <div class="flex">
                    <svg class="w-5 h-5 text-purple-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                    </svg>
                    <p class="text-purple-700">Los análisis predictivos y comparativos estarán disponibles próximamente.</p>
                  </div>
                </div>
              </div>

              <!-- TAB 6: Gráficos -->
              <div *ngIf="tabActual === 'graficos'" class="space-y-6">
                <app-notas-grafico [actividades]="getActividadesEntregadas()"></app-notas-grafico>
              </div>

            </div>
          </div>
        </div>

        
      </main>
    </div>
  `,
})
export class AlumnoMateriaDetalleComponent implements OnInit {
  materiaId!: number;
  cargando = true;
  error = '';

  // Datos de la materia
  detalleMateria: any = {
    nombre: '',
    profesor: '',
    promedio: 0,
    curso: ''
  };

  actividades: any[] = [];
  asistencia: any = {
    total_clases: 0,
    clases_asistidas: 0,
    clases_perdidas: 0,
    porcentaje: 0,
    historial_semanal: []
  };

  // Sistema de pestañas
  tabActual = 'info';

  // 👈 Usar la interfaz Tab con tipado correcto
  tabs: Tab[] = [
    {
      id: 'info',
      label: 'Información',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
      badge: null
    },
    {
      id: 'asistencia',
      label: 'Asistencia',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>',
      badge: null
    },
    {
      id: 'actividades',
      label: 'Actividades',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>',
      badge: null
    },
    {
      id: 'notas',
      label: 'Notas',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>',
      badge: null
    },
    {
      id: 'analisis',
      label: 'Análisis',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path></svg>',
      badge: null
    },

    {
      id: 'graficos',
      label: 'Gráficos',
      icon: '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 17v-6m4 6V7m-8 10v-2"></path></svg>',
      badge: null
    }
  ];
  prediccionNota: string | null = null;
  cargandoPrediccion = false;
  
  // 🔥 AGREGAR FECHA ACTUAL PARA EL TEMPLATE
  fechaActual = new Date().toISOString();

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private alumnoService: AlumnoService,
    private http: HttpClient // 👈 Agrega HttpClient
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe(params => {
      this.materiaId = +params['id'];
      this.cargarDatosMateria();
    });
  }

  // Métodos del sistema de pestañas
  cambiarTab(tabId: string): void {
    this.tabActual = tabId;
  }

  getTabClass(tabId: string): string {
    const baseClass = 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300';
    const activeClass = 'border-blue-500 text-blue-600';
    
    return this.tabActual === tabId ? activeClass : baseClass;
  }

  // Métodos de tracking para Angular
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

  // Cargar datos de la materia
  cargarDatosMateria(): void {
    this.cargando = true;
    this.error = '';

    this.alumnoService.getDetalleMateriaAlumno(this.materiaId).subscribe({
      next: (data) => {
        this.detalleMateria = data.materia;
        this.actividades = data.actividades;
        this.asistencia = data.asistencia;
        
        // Actualizar badges de las pestañas
        this.actualizarBadgesTabs();
        
        this.cargando = false;
      },
      error: (err) => {
        console.error('Error al cargar detalle de materia:', err);
        this.error = 'Error al cargar los datos de la materia';
        this.cargando = false;
      }
    });
  }

  private actualizarBadgesTabs(): void {
    // Actualizar badges con información dinámica
    const actividadesTab = this.tabs.find(t => t.id === 'actividades');
    if (actividadesTab) {
      actividadesTab.badge = this.actividades.length.toString(); // 👈 Ahora funciona
    }

    const asistenciaTab = this.tabs.find(t => t.id === 'asistencia');
    if (asistenciaTab) {
      asistenciaTab.badge = `${this.asistencia.porcentaje}%`; // 👈 Ahora funciona
    }
  }

  volver(): void {
    this.router.navigate(['/mi-rendimiento']);
  }

  // Nuevos métodos para el componente

  // Obtener solo actividades entregadas
  getActividadesEntregadas(): any[] {
    return this.actividades.filter(actividad => 
      actividad.estado === 'Entregado' || actividad.entregado === true
    );
  }

  // Nuevos métodos para manejo de asistencia

  // Calcular la nota de asistencia
  calcularNotaAsistencia(): number {
    // Si el porcentaje ya viene calculado, lo usamos directamente
    if (this.asistencia.porcentaje !== undefined && this.asistencia.porcentaje !== null) {
      return this.asistencia.porcentaje;
    }
    
    // Si hay que calcularlo
    if (this.asistencia.total_clases && this.asistencia.total_clases > 0) {
      const porcentaje = (this.asistencia.clases_asistidas / this.asistencia.total_clases) * 100;
      return Math.round(porcentaje);
    }
    
    // Si no hay datos suficientes, devolvemos 100%
    return 100;
  }

  // Calcular promedio por dimensión incluyendo asistencia
  calcularPromedioPorDimension(dimension: string, incluirAsistencia: boolean = false): string {
    const actividadesDimension = this.getActividadesEntregadas().filter(
      act => act.dimension?.toLowerCase() === dimension.toLowerCase()
    );
    
    // Lista de calificaciones
    let calificaciones: number[] = [];
    
    // Agregar notas de actividades
    actividadesDimension.forEach(act => {
      if (act.nota !== undefined && act.nota !== null) {
        calificaciones.push(Number(act.nota));
      }
    });
    
    // Agregar nota de asistencia en dimensión "ser" si se solicita
    if (dimension === 'ser' && incluirAsistencia) {
      calificaciones.push(this.calcularNotaAsistencia());
    }
    
    // Calcular promedio
    if (calificaciones.length === 0) {
      return 'N/A';
    }
    
    const suma = calificaciones.reduce((acc, nota) => acc + nota, 0);
    return (suma / calificaciones.length).toFixed(1);
  }

  // Calcular promedio general incluyendo asistencia
  calcularPromedioGeneral(incluirAsistencia: boolean = false): string {
    const actividadesEntregadas = this.getActividadesEntregadas();
    const calificaciones: number[] = [];
    
    // Agregar notas de actividades
    actividadesEntregadas.forEach(act => {
      if (act.nota !== undefined && act.nota !== null) {
        calificaciones.push(Number(act.nota));
      }
    });
    
    // Agregar nota de asistencia si se solicita
    if (incluirAsistencia) {
      calificaciones.push(this.calcularNotaAsistencia());
    }
    
    // Calcular promedio
    if (calificaciones.length === 0) {
      return 'N/A';
    }
    
    const suma = calificaciones.reduce((acc, nota) => acc + nota, 0);
    return (suma / calificaciones.length).toFixed(1);
  }

  // Llama a la predicción de nota
  predecirNotaFinal() {
    this.cargandoPrediccion = true;
    this.prediccionNota = null;

    const actividadesEntregadas = this.getActividadesEntregadas();
    const payload = {
      actividades: actividadesEntregadas.map(act => ({
        dimension: act.dimension,
        nota: act.nota
      })),
      asistencia_porcentaje: this.asistencia.porcentaje
    };

    // Cambiar la URL para usar environment
    this.http.post<any>(environment.apiUrl + 'api/predecir/', payload)
      .subscribe({
        next: (response) => {
          this.prediccionNota = Math.round(response.nota_predicha).toString();
          this.cargandoPrediccion = false;
        },
        error: (error) => {
          console.error('Error en predicción:', error);
          this.cargandoPrediccion = false;
        }
      });
  }
}