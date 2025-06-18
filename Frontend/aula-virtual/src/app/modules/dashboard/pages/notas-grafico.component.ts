import { Component, Input, OnChanges, SimpleChanges, ElementRef, ViewChild, AfterViewInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Chart, ChartConfiguration, ChartData, registerables } from 'chart.js';

// Registrar todos los componentes de Chart.js
Chart.register(...registerables);

interface Actividad {
  id?: number;
  nombre?: string;
  titulo?: string;
  dimension: 'ser' | 'saber' | 'hacer' | 'decidir';
  nota: number;
  fecha_entrega?: string;
  fecha_creacion?: string;
  estado?: string;
  descripcion?: string;
  tipo?: string;
}

@Component({
  selector: 'app-notas-grafico',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="bg-gradient-to-br from-white to-gray-50 rounded-xl shadow-lg p-6 border border-gray-100">
      <!-- Header con estadísticas y controles -->
      <div class="mb-6">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h3 class="text-2xl font-bold text-gray-800 mb-1 flex items-center">
              <svg class="w-7 h-7 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              </svg>
              {{ mostrarPorActividad ? 'Notas por Actividad y Dimensión' : 'Evolución de Notas por Dimensión' }}
            </h3>
            <p class="text-gray-600">
              {{ mostrarPorActividad ? 
                'Comparación de notas por dimensión en cada actividad específica' : 
                'Seguimiento del progreso académico a través del tiempo'
              }}
            </p>
          </div>
          <div class="text-right space-y-1">
            <div class="text-sm text-gray-500">Promedio General</div>
            <div class="text-3xl font-bold" [class]="getColorClasePromedio(promedioGeneral)">
              {{ promedioGeneral }}%
            </div>
            <div class="text-xs text-gray-500">{{ actividadesValidas.length }} actividades</div>
          </div>
        </div>

        <!-- Toggle para cambiar vista -->
        <div class="flex items-center justify-center mb-4">
          <div class="bg-gray-100 rounded-lg p-1 flex">
            <button 
              (click)="mostrarPorActividad = false; actualizarGrafico()"
              [class]="!mostrarPorActividad ? 'bg-white shadow-sm text-blue-600 font-medium' : 'text-gray-600'"
              class="px-4 py-2 rounded-md text-sm transition-all duration-200 flex items-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
              </svg>
              Por Tiempo
            </button>
            <button 
              (click)="mostrarPorActividad = true; actualizarGrafico()"
              [class]="mostrarPorActividad ? 'bg-white shadow-sm text-blue-600 font-medium' : 'text-gray-600'"
              class="px-4 py-2 rounded-md text-sm transition-all duration-200 flex items-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v6a2 2 0 002 2h2m0 0h10a2 2 0 002-2V7a2 2 0 00-2-2H9m0 12v-3m0 0h10v3M9 14h10"></path>
              </svg>
              Por Actividad
            </button>
          </div>
        </div>
        
        <!-- Estadísticas rápidas mejoradas -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
          <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg p-4 border border-purple-200 relative overflow-hidden">
            <div class="relative z-10">
              <div class="text-xs font-medium text-purple-600 uppercase tracking-wide mb-1">Ser</div>
              <div class="text-xl font-bold text-purple-700 flex items-center">
                {{ getPromedioDimension('ser') }}%
                <span class="ml-2" [innerHTML]="getTendenciaIcon(getTendenciaDimension('ser'))"></span>
              </div>
              <div class="text-xs text-purple-500">{{ getContadorDimension('ser') }} actividades</div>
              <div class="text-xs text-purple-600 font-medium mt-1">
                {{ mejorDimension === 'ser' ? '🏆 Mejor' : peorDimension === 'ser' ? '📈 A mejorar' : '' }}
              </div>
            </div>
            <div class="absolute top-0 right-0 w-16 h-16 bg-purple-200 rounded-full -mr-8 -mt-8 opacity-20"></div>
          </div>

          <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4 border border-blue-200 relative overflow-hidden">
            <div class="relative z-10">
              <div class="text-xs font-medium text-blue-600 uppercase tracking-wide mb-1">Saber</div>
              <div class="text-xl font-bold text-blue-700 flex items-center">
                {{ getPromedioDimension('saber') }}%
                <span class="ml-2" [innerHTML]="getTendenciaIcon(getTendenciaDimension('saber'))"></span>
              </div>
              <div class="text-xs text-blue-500">{{ getContadorDimension('saber') }} actividades</div>
              <div class="text-xs text-blue-600 font-medium mt-1">
                {{ mejorDimension === 'saber' ? '🏆 Mejor' : peorDimension === 'saber' ? '📈 A mejorar' : '' }}
              </div>
            </div>
            <div class="absolute top-0 right-0 w-16 h-16 bg-blue-200 rounded-full -mr-8 -mt-8 opacity-20"></div>
          </div>

          <div class="bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-lg p-4 border border-yellow-200 relative overflow-hidden">
            <div class="relative z-10">
              <div class="text-xs font-medium text-yellow-600 uppercase tracking-wide mb-1">Hacer</div>
              <div class="text-xl font-bold text-yellow-700 flex items-center">
                {{ getPromedioDimension('hacer') }}%
                <span class="ml-2" [innerHTML]="getTendenciaIcon(getTendenciaDimension('hacer'))"></span>
              </div>
              <div class="text-xs text-yellow-500">{{ getContadorDimension('hacer') }} actividades</div>
              <div class="text-xs text-yellow-600 font-medium mt-1">
                {{ mejorDimension === 'hacer' ? '🏆 Mejor' : peorDimension === 'hacer' ? '📈 A mejorar' : '' }}
              </div>
            </div>
            <div class="absolute top-0 right-0 w-16 h-16 bg-yellow-200 rounded-full -mr-8 -mt-8 opacity-20"></div>
          </div>

          <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4 border border-green-200 relative overflow-hidden">
            <div class="relative z-10">
              <div class="text-xs font-medium text-green-600 uppercase tracking-wide mb-1">Decidir</div>
              <div class="text-xl font-bold text-green-700 flex items-center">
                {{ getPromedioDimension('decidir') }}%
                <span class="ml-2" [innerHTML]="getTendenciaIcon(getTendenciaDimension('decidir'))"></span>
              </div>
              <div class="text-xs text-green-500">{{ getContadorDimension('decidir') }} actividades</div>
              <div class="text-xs text-green-600 font-medium mt-1">
                {{ mejorDimension === 'decidir' ? '🏆 Mejor' : peorDimension === 'decidir' ? '📈 A mejorar' : '' }}
              </div>
            </div>
            <div class="absolute top-0 right-0 w-16 h-16 bg-green-200 rounded-full -mr-8 -mt-8 opacity-20"></div>
          </div>
        </div>

        <!-- Análisis de tendencia -->
        <div class="bg-gradient-to-r from-indigo-50 to-blue-50 rounded-lg p-4 border border-indigo-200 mb-4" 
             *ngIf="actividadesValidas.length > 2">
          <div class="flex items-center">
            <div class="text-2xl mr-3">
              {{ tendencia === 'ascendente' ? '📈' : tendencia === 'descendente' ? '📉' : '➡️' }}
            </div>
            <div>
              <div class="font-semibold text-indigo-800">
                Tendencia General: 
                <span [class]="getTendenciaColorClass()">
                  {{ getTendenciaTexto() }}
                </span>
              </div>
              <div class="text-sm text-indigo-600 mt-1">
                {{ getAnalisisTendencia() }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Gráfico -->
      <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-100 mb-4" 
           *ngIf="actividadesValidas.length > 0; else noDataTemplate">
        <canvas #chartCanvas 
                class="w-full"
                [style.height.px]="altura">
        </canvas>
      </div>

      <!-- Template cuando no hay datos -->
      <ng-template #noDataTemplate>
        <div class="bg-white rounded-lg p-12 shadow-sm border border-gray-100 text-center">
          <div class="text-gray-400 mb-6">
            <svg class="w-20 h-20 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" 
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z">
              </path>
            </svg>
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-3">No hay datos disponibles</h3>
          <p class="text-gray-500 mb-4">Agrega actividades con notas para ver el análisis de evolución.</p>
          <div class="bg-blue-50 rounded-lg p-4 inline-block">
            <p class="text-sm text-blue-700">
              💡 <strong>Tip:</strong> Las actividades deben tener asignada una dimensión y una nota válida.
            </p>
          </div>
        </div>
      </ng-template>

      <!-- Leyenda mejorada con información adicional -->
      <div class="space-y-4">
        <div class="flex flex-wrap justify-center gap-6 text-sm">
          <div class="flex items-center group cursor-pointer transform hover:scale-105 transition-transform">
            <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
                 style="background: linear-gradient(135deg, #a855f7, #c084fc)"></div>
            <span class="font-medium text-gray-700 group-hover:text-purple-600 transition-colors">
              Ser (Actitudes y valores)
            </span>
          </div>
          <div class="flex items-center group cursor-pointer transform hover:scale-105 transition-transform">
            <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
                 style="background: linear-gradient(135deg, #2563eb, #60a5fa)"></div>
            <span class="font-medium text-gray-700 group-hover:text-blue-600 transition-colors">
              Saber (Conocimientos)
            </span>
          </div>
          <div class="flex items-center group cursor-pointer transform hover:scale-105 transition-transform">
            <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
                 style="background: linear-gradient(135deg, #facc15, #fde047)"></div>
            <span class="font-medium text-gray-700 group-hover:text-yellow-600 transition-colors">
              Hacer (Habilidades)
            </span>
          </div>
          <div class="flex items-center group cursor-pointer transform hover:scale-105 transition-transform">
            <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
                 style="background: linear-gradient(135deg, #22c55e, #4ade80)"></div>
            <span class="font-medium text-gray-700 group-hover:text-green-600 transition-colors">
              Decidir (Decisiones)
            </span>
          </div>
        </div>

        <!-- Información interpretativa mejorada -->
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-4 border border-blue-100">
          <div class="flex items-start">
            <svg class="w-6 h-6 text-blue-500 mt-0.5 mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
            </svg>
            <div class="text-sm text-blue-700">
              <p class="font-semibold mb-2">Interpretación del gráfico:</p>
              <ul class="space-y-1 text-xs">
                <li *ngIf="!mostrarPorActividad">• <strong>Vista por Tiempo:</strong> Muestra la evolución de cada dimensión a lo largo del tiempo.</li>
                <li *ngIf="mostrarPorActividad">• <strong>Vista por Actividad:</strong> Compara el rendimiento en las 4 dimensiones para cada actividad.</li>
                <li>• Las líneas conectan los puntos para mostrar patrones y tendencias.</li>
                <li>• Los puntos más altos indican mejor rendimiento en esa dimensión.</li>
                <li>• Usa el toggle superior para cambiar entre las dos vistas disponibles.</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Recomendaciones personalizadas -->
        <div class="bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg p-4 border border-green-100" 
             *ngIf="actividadesValidas.length > 0">
          <div class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
            </svg>
            <div class="text-sm text-green-700">
              <p class="font-semibold mb-2">Recomendaciones:</p>
              <div class="text-xs space-y-1">
                <p *ngIf="peorDimension">• Enfocar esfuerzos en mejorar la dimensión <strong>{{ peorDimension.toUpperCase() }}</strong> (promedio: {{ getPromedioDimension(peorDimension) }}%)</p>
                <p *ngIf="mejorDimension">• Mantener el buen rendimiento en <strong>{{ mejorDimension.toUpperCase() }}</strong> (promedio: {{ getPromedioDimension(mejorDimension) }}%)</p>
                <p *ngIf="tendencia === 'descendente'">• La tendencia descendente sugiere revisar las estrategias de estudio</p>
                <p *ngIf="tendencia === 'ascendente'">• ¡Excelente! La tendencia ascendente muestra progreso constante</p>
                <p *ngIf="promedioGeneral < 70">• El promedio general está por debajo del 70%, considera buscar apoyo adicional</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `
})
export class NotasGraficoComponent implements OnChanges, AfterViewInit, OnDestroy {
  @Input() actividades: Actividad[] = [];
  @Input() mostrarPorActividad: boolean = false;
  @Input() altura: number = 400;
  
  @ViewChild('chartCanvas', { static: true }) chartCanvas!: ElementRef<HTMLCanvasElement>;
  private chart?: Chart;
  
  actividadesValidas: Actividad[] = [];
  mejorDimension: string = '';
  peorDimension: string = '';
  tendencia: 'ascendente' | 'descendente' | 'estable' = 'estable';
  promedioGeneral: number = 0;

  ngAfterViewInit(): void {
    this.actualizarActividadesValidas();
    this.calcularEstadisticas();
    this.crearGrafico();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['actividades']) {
      this.actualizarActividadesValidas();
      this.calcularEstadisticas();
      if (this.chart) {
        this.actualizarGrafico();
      }
    }
  }

  ngOnDestroy(): void {
    if (this.chart) {
      this.chart.destroy();
    }
  }

  private actualizarActividadesValidas(): void {
    this.actividadesValidas = this.actividades.filter(
      a => a && a.dimension && a.nota !== null && a.nota !== undefined && a.nota >= 0
    );
  }

  private crearGrafico(): void {
    if (!this.chartCanvas?.nativeElement || this.actividadesValidas.length === 0) return;

    const ctx = this.chartCanvas.nativeElement.getContext('2d');
    if (!ctx) return;

    this.chart = new Chart(ctx, {
      type: 'line',
      data: this.getChartData(),
      options: this.getChartOptions()
    });
  }

  public actualizarGrafico(): void {
    if (!this.chart) return;
    
    this.chart.data = this.getChartData();
    this.chart.update();
  }

  private getChartData(): ChartData<'line'> {
    if (this.actividadesValidas.length === 0) {
      return { labels: [], datasets: [] };
    }

    // Ordenar actividades por fecha
    const actividadesOrdenadas = [...this.actividadesValidas]
      .sort((a, b) => {
        const fechaA = new Date(a.fecha_entrega || a.fecha_creacion || '').getTime();
        const fechaB = new Date(b.fecha_entrega || b.fecha_creacion || '').getTime();
        return fechaA - fechaB;
      });

    // Generar fechas únicas
    const fechasUnicas = Array.from(
      new Set(
        actividadesOrdenadas.map(a => {
          const fecha = new Date(a.fecha_entrega || a.fecha_creacion || '');
          return fecha.toLocaleDateString('es-ES', { 
            day: '2-digit', 
            month: '2-digit',
            year: '2-digit'
          });
        })
      )
    );

    // Helper para obtener notas por dimensión
    const getNotasPorDimension = (dimension: string) =>
      fechasUnicas.map(fecha => {
        const actividad = actividadesOrdenadas.find(a => {
          const fechaActividad = new Date(a.fecha_entrega || a.fecha_creacion || '');
          const fechaFormateada = fechaActividad.toLocaleDateString('es-ES', { 
            day: '2-digit', 
            month: '2-digit',
            year: '2-digit'
          });
          return a.dimension === dimension && fechaFormateada === fecha;
        });
        return actividad ? actividad.nota : null;
      });

    const datasets = [
      {
        label: 'Ser',
        data: getNotasPorDimension('ser'),
        borderColor: '#a855f7',
        backgroundColor: 'rgba(168, 85, 247, 0.1)',
        tension: 0.4,
        fill: false,
        pointRadius: 6,
        pointBackgroundColor: '#a855f7',
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointHoverRadius: 8,
        spanGaps: true
      },
      {
        label: 'Saber',
        data: getNotasPorDimension('saber'),
        borderColor: '#2563eb',
        backgroundColor: 'rgba(37, 99, 235, 0.1)',
        tension: 0.4,
        fill: false,
        pointRadius: 6,
        pointBackgroundColor: '#2563eb',
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointHoverRadius: 8,
        spanGaps: true
      },
      {
        label: 'Hacer',
        data: getNotasPorDimension('hacer'),
        borderColor: '#facc15',
        backgroundColor: 'rgba(250, 204, 21, 0.1)',
        tension: 0.4,
        fill: false,
        pointRadius: 6,
        pointBackgroundColor: '#facc15',
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointHoverRadius: 8,
        spanGaps: true
      },
      {
        label: 'Decidir',
        data: getNotasPorDimension('decidir'),
        borderColor: '#22c55e',
        backgroundColor: 'rgba(34, 197, 94, 0.1)',
        tension: 0.4,
        fill: false,
        pointRadius: 6,
        pointBackgroundColor: '#22c55e',
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointHoverRadius: 8,
        spanGaps: true
      }
    ].filter(dataset => dataset.data.some(value => value !== null));

    return {
      labels: fechasUnicas,
      datasets
    };
  }

  private getChartOptions(): ChartConfiguration<'line'>['options'] {
    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        intersect: false,
        mode: 'index'
      },
      plugins: {
        legend: { 
          display: false
        },
        tooltip: { 
          enabled: true,
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          titleColor: '#fff',
          bodyColor: '#fff',
          borderColor: '#e5e7eb',
          borderWidth: 1,
          cornerRadius: 8,
          displayColors: true,
          callbacks: {
            title: (context) => `Fecha: ${context[0].label}`,
            label: (context) => `${context.dataset.label}: ${context.parsed.y}%`
          }
        }
      },
      scales: {
        y: {
          min: 0,
          max: 100,
          title: { 
            display: true, 
            text: 'Nota (%)',
            font: { weight: 'bold' }
          },
          grid: {
            color: 'rgba(0, 0, 0, 0.05)'
          },
          ticks: {
            callback: function(value) {
              return value + '%';
            }
          }
        },
        x: {
          title: { 
            display: true, 
            text: 'Fecha de Entrega',
            font: { weight: 'bold' }
          },
          grid: {
            color: 'rgba(0, 0, 0, 0.05)'
          }
        }
      },
      elements: {
        line: {
          borderWidth: 3
        },
        point: {
          radius: 6,
          hoverRadius: 8,
          borderWidth: 2
        }
      }
    };
  }

  // Métodos auxiliares (conservados del código original)
  getColorClasePromedio(promedio: number): string {
    if (promedio >= 90) return 'text-green-600';
    if (promedio >= 80) return 'text-blue-600';
    if (promedio >= 70) return 'text-yellow-600';
    if (promedio >= 60) return 'text-orange-600';
    return 'text-red-600';
  }

  getTendenciaDimension(dimension: string): 'ascendente' | 'descendente' | 'estable' {
    const actividadesDimension = this.actividadesValidas
      .filter(a => a.dimension === dimension)
      .sort((a, b) => {
        const fechaA = new Date(a.fecha_entrega || a.fecha_creacion || '').getTime();
        const fechaB = new Date(b.fecha_entrega || b.fecha_creacion || '').getTime();
        return fechaA - fechaB;
      });

    if (actividadesDimension.length < 2) return 'estable';

    const primera = actividadesDimension[0].nota;
    const ultima = actividadesDimension[actividadesDimension.length - 1].nota;
    const diferencia = ultima - primera;

    if (diferencia > 5) return 'ascendente';
    if (diferencia < -5) return 'descendente';
    return 'estable';
  }

  getTendenciaIcon(tendencia: 'ascendente' | 'descendente' | 'estable'): string {
    switch (tendencia) {
      case 'ascendente':
        return '<svg class="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L11 5.414V17a1 1 0 11-2 0V5.414L4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd"></path></svg>';
      case 'descendente':
        return '<svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 10.293a1 1 0 010 1.414l-6 6a1 1 0 01-1.414 0l-6-6a1 1 0 111.414-1.414L9 14.586V3a1 1 0 012 0v11.586l4.293-4.293a1 1 0 011.414 0z" clip-rule="evenodd"></path></svg>';
      default:
        return '<svg class="w-4 h-4 text-gray-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path></svg>';
    }
  }

  getTendenciaColorClass(): string {
    switch (this.tendencia) {
      case 'ascendente': return 'text-green-600 font-semibold';
      case 'descendente': return 'text-red-600 font-semibold';
      default: return 'text-gray-600 font-semibold';
    }
  }

  getTendenciaTexto(): string {
    switch (this.tendencia) {
      case 'ascendente': return 'En Mejora';
      case 'descendente': return 'En Declive';
      default: return 'Estable';
    }
  }

  getAnalisisTendencia(): string {
    const totalActividades = this.actividadesValidas.length;
    
    switch (this.tendencia) {
      case 'ascendente':
        return `Las notas han mostrado una mejora consistente en las últimas ${totalActividades} actividades.`;
      case 'descendente':
        return `Se observa una tendencia decreciente en las últimas ${totalActividades} actividades que requiere atención.`;
      default:
        return `El rendimiento se ha mantenido relativamente estable en las últimas ${totalActividades} actividades.`;
    }
  }

  private calcularEstadisticas(): void {
    if (this.actividadesValidas.length === 0) return;

    // Calcular promedios por dimensión
    const dimensiones = ['ser', 'saber', 'hacer', 'decidir'];
    const promedios: { [key: string]: number } = {};

    dimensiones.forEach(dim => {
      const promedio = parseFloat(this.getPromedioDimension(dim));
      promedios[dim] = promedio;
    });

    // Encontrar mejor y peor dimensión
    const dimensionesConDatos = Object.entries(promedios).filter(([_, promedio]) => promedio > 0);
    
    if (dimensionesConDatos.length > 0) {
      this.mejorDimension = dimensionesConDatos.reduce((a, b) => a[1] > b[1] ? a : b)[0];
      this.peorDimension = dimensionesConDatos.reduce((a, b) => a[1] < b[1] ? a : b)[0];
    }

    // Calcular promedio general
    const todasLasNotas = this.actividadesValidas.map(a => a.nota);
    this.promedioGeneral = Math.round(
      todasLasNotas.reduce((sum, nota) => sum + nota, 0) / todasLasNotas.length
    );

    // Calcular tendencia general
    this.calcularTendenciaGeneral();
  }

  private calcularTendenciaGeneral(): void {
    if (this.actividadesValidas.length < 3) {
      this.tendencia = 'estable';
      return;
    }

    const actividadesOrdenadas = [...this.actividadesValidas]
      .sort((a, b) => {
        const fechaA = new Date(a.fecha_entrega || a.fecha_creacion || '').getTime();
        const fechaB = new Date(b.fecha_entrega || b.fecha_creacion || '').getTime();
        return fechaA - fechaB;
      });

    // Tomar las primeras y últimas 3 actividades para comparar
    const primeras = actividadesOrdenadas.slice(0, 3);
    const ultimas = actividadesOrdenadas.slice(-3);

    const promedioPrimeras = primeras.reduce((sum, a) => sum + a.nota, 0) / primeras.length;
    const promedioUltimas = ultimas.reduce((sum, a) => sum + a.nota, 0) / ultimas.length;

    const diferencia = promedioUltimas - promedioPrimeras;

    if (diferencia > 5) this.tendencia = 'ascendente';
    else if (diferencia < -5) this.tendencia = 'descendente';
    else this.tendencia = 'estable';
  }

  getPromedioDimension(dimension: string): string {
    const actividadesDimension = this.actividadesValidas.filter(a => a.dimension === dimension);
    if (actividadesDimension.length === 0) return '0';
    
    const suma = actividadesDimension.reduce((acc, act) => acc + act.nota, 0);
    return Math.round(suma / actividadesDimension.length).toString();
  }

  getContadorDimension(dimension: string): number {
    return this.actividadesValidas.filter(a => a.dimension === dimension).length;
  }
}
