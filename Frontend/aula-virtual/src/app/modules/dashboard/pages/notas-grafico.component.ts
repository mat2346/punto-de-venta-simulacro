import { Component, Input, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ChartType, ChartData, ChartOptions } from 'chart.js';
import { BaseChartDirective } from 'ng2-charts';

interface Actividad {
  id?: number;
  nombre?: string;
  dimension: 'ser' | 'saber' | 'hacer' | 'decidir';
  nota: number;
  fecha_entrega?: string;
  fecha_creacion?: string;
  estado?: string;
}

type TipoVista = 'fecha' | 'actividad';

@Component({
  selector: 'app-notas-grafico',
  standalone: true,
  imports: [CommonModule, BaseChartDirective],
  template: `
    <div class="bg-gradient-to-br from-white to-gray-50 rounded-xl shadow-lg p-6 border border-gray-100">
      <!-- Header con estadísticas -->
      <div class="mb-6">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h3 class="text-2xl font-bold text-gray-800 mb-1">
              Evolución de Notas por Dimensión
            </h3>
            <p class="text-gray-600">
              Seguimiento del progreso académico
            </p>
          </div>
          <div class="text-right">
            <div class="text-sm text-gray-500">Total de actividades</div>
            <div class="text-2xl font-bold text-blue-600">{{ actividadesValidas.length }}</div>
          </div>
        </div>
        
        <!-- Selector de vista -->
        <div class="flex justify-center mb-4">
          <div class="bg-white rounded-lg p-1 shadow-sm border border-gray-200 inline-flex">
            <button 
              (click)="cambiarTipoVista('fecha')"
              [class]="tipoVista === 'fecha' ? 'bg-blue-500 text-white shadow-sm' : 'text-gray-600 hover:text-gray-800'"
              class="px-4 py-2 rounded-md text-sm font-medium transition-all duration-200 ease-in-out">
              <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
              Por Fecha
            </button>
            <button 
              (click)="cambiarTipoVista('actividad')"
              [class]="tipoVista === 'actividad' ? 'bg-blue-500 text-white shadow-sm' : 'text-gray-600 hover:text-gray-800'"
              class="px-4 py-2 rounded-md text-sm font-medium transition-all duration-200 ease-in-out">
              <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              Por Actividad
            </button>
          </div>
        </div>
        
        <!-- Estadísticas rápidas -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
          <div class="bg-purple-50 rounded-lg p-3 border border-purple-100">
            <div class="text-xs font-medium text-purple-600 uppercase tracking-wide">Ser</div>
            <div class="text-lg font-bold text-purple-700">{{ getPromedioDimension('ser') }}%</div>
            <div class="text-xs text-purple-500">{{ getContadorDimension('ser') }} actividades</div>
          </div>
          <div class="bg-blue-50 rounded-lg p-3 border border-blue-100">
            <div class="text-xs font-medium text-blue-600 uppercase tracking-wide">Saber</div>
            <div class="text-lg font-bold text-blue-700">{{ getPromedioDimension('saber') }}%</div>
            <div class="text-xs text-blue-500">{{ getContadorDimension('saber') }} actividades</div>
          </div>
          <div class="bg-yellow-50 rounded-lg p-3 border border-yellow-100">
            <div class="text-xs font-medium text-yellow-600 uppercase tracking-wide">Hacer</div>
            <div class="text-lg font-bold text-yellow-700">{{ getPromedioDimension('hacer') }}%</div>
            <div class="text-xs text-yellow-500">{{ getContadorDimension('hacer') }} actividades</div>
          </div>
          <div class="bg-green-50 rounded-lg p-3 border border-green-100">
            <div class="text-xs font-medium text-green-600 uppercase tracking-wide">Decidir</div>
            <div class="text-lg font-bold text-green-700">{{ getPromedioDimension('decidir') }}%</div>
            <div class="text-xs text-green-500">{{ getContadorDimension('decidir') }} actividades</div>
          </div>
        </div>
      </div>

      <!-- Gráfico -->
      <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-100 mb-4" 
           *ngIf="actividadesValidas.length > 0; else noDataTemplate">
        <canvas baseChart
          [data]="lineChartData"
          [options]="lineChartOptions"
          [type]="lineChartType"
          class="w-full"
          style="height: 400px;">
        </canvas>
      </div>

      <!-- Template cuando no hay datos -->
      <ng-template #noDataTemplate>
        <div class="bg-white rounded-lg p-8 shadow-sm border border-gray-100 text-center">
          <div class="text-gray-400 mb-4">
            <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z">
              </path>
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">No hay datos disponibles</h3>
          <p class="text-gray-500">Agrega actividades con notas para ver el gráfico de evolución.</p>
        </div>
      </ng-template>

      <!-- Leyenda mejorada -->
      <div class="flex flex-wrap justify-center gap-6 text-sm">
        <div class="flex items-center group cursor-pointer">
          <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
               style="background: linear-gradient(135deg, #a855f7, #c084fc)"></div>
          <span class="font-medium text-gray-700 group-hover:text-purple-600 transition-colors">
            Ser (Actitudes y valores)
          </span>
        </div>
        <div class="flex items-center group cursor-pointer">
          <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
               style="background: linear-gradient(135deg, #2563eb, #60a5fa)"></div>
          <span class="font-medium text-gray-700 group-hover:text-blue-600 transition-colors">
            Saber (Conocimientos)
          </span>
        </div>
        <div class="flex items-center group cursor-pointer">
          <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
               style="background: linear-gradient(135deg, #facc15, #fde047)"></div>
          <span class="font-medium text-gray-700 group-hover:text-yellow-600 transition-colors">
            Hacer (Habilidades)
          </span>
        </div>
        <div class="flex items-center group cursor-pointer">
          <div class="w-4 h-4 rounded-full mr-2 shadow-sm border-2 border-white" 
               style="background: linear-gradient(135deg, #22c55e, #4ade80)"></div>
          <span class="font-medium text-gray-700 group-hover:text-green-600 transition-colors">
            Decidir (Decisiones)
          </span>
        </div>
      </div>

      <!-- Información adicional -->
      <div class="mt-4 p-3 bg-blue-50 rounded-lg border border-blue-100">
        <div class="flex items-start">
          <svg class="w-5 h-5 text-blue-500 mt-0.5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
          </svg>
          <div class="text-sm text-blue-700">
            <p class="font-medium mb-1">Interpretación del gráfico:</p>
            <p *ngIf="tipoVista === 'fecha'">
              Cada línea representa el progreso en una dimensión específica a lo largo del tiempo. Los puntos muestran las notas obtenidas en cada actividad ordenadas por fecha.
            </p>
            <p *ngIf="tipoVista === 'actividad'">
              Cada línea representa una dimensión específica. Los puntos muestran las notas obtenidas, donde cada actividad se presenta en orden secuencial independientemente de la fecha.
            </p>
          </div>
        </div>
      </div>
    </div>
  `
})
export class NotasGraficoComponent implements OnChanges {
  @Input() actividades: Actividad[] = [];
  
  actividadesValidas: Actividad[] = [];
  lineChartType: ChartType = 'line';
  tipoVista: TipoVista = 'fecha';

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['actividades']) {
      this.actualizarActividadesValidas();
    }
  }

  private actualizarActividadesValidas(): void {
    this.actividadesValidas = this.actividades.filter(
      a => a && a.dimension && a.nota !== null && a.nota !== undefined && a.nota >= 0
    );
  }

  cambiarTipoVista(tipo: TipoVista): void {
    this.tipoVista = tipo;
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

  get lineChartOptions(): ChartOptions {
    const baseOptions: ChartOptions = {
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
            title: (context) => {
              if (this.tipoVista === 'fecha') {
                return `Fecha: ${context[0].label}`;
              } else {
                return `Actividad: ${context[0].label}`;
              }
            },
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
            text: this.tipoVista === 'fecha' ? 'Fecha de Entrega' : 'Actividades',
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

    return baseOptions;
  }

  get lineChartData(): ChartData<'line'> {
    if (this.actividadesValidas.length === 0) {
      return { labels: [], datasets: [] };
    }

    if (this.tipoVista === 'fecha') {
      return this.getChartDataPorFecha();
    } else {
      return this.getChartDataPorActividad();
    }
  }

  private getChartDataPorFecha(): ChartData<'line'> {
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

  private getChartDataPorActividad(): ChartData<'line'> {
    // Ordenar actividades por fecha o ID para mantener un orden consistente
    const actividadesOrdenadas = [...this.actividadesValidas]
      .sort((a, b) => {
        const fechaA = new Date(a.fecha_entrega || a.fecha_creacion || '').getTime();
        const fechaB = new Date(b.fecha_entrega || b.fecha_creacion || '').getTime();
        if (fechaA !== fechaB) return fechaA - fechaB;
        return (a.id || 0) - (b.id || 0);
      });

    // Generar labels con nombres de actividades (limitados a 20 caracteres)
    const labels = actividadesOrdenadas.map((actividad, index) => {
      const nombre = actividad.nombre || `Actividad ${index + 1}`;
      return nombre.length > 20 ? nombre.substring(0, 17) + '...' : nombre;
    });

    // Crear datasets por dimensión
    const dimensiones = ['ser', 'saber', 'hacer', 'decidir'];
    const colores = {
      'ser': '#a855f7',
      'saber': '#2563eb', 
      'hacer': '#facc15',
      'decidir': '#22c55e'
    };

    const datasets = dimensiones.map(dimension => {
      const data = actividadesOrdenadas.map(actividad => 
        actividad.dimension === dimension ? actividad.nota : null
      );

      return {
        label: dimension.charAt(0).toUpperCase() + dimension.slice(1),
        data,
        borderColor: colores[dimension as keyof typeof colores],
        backgroundColor: `${colores[dimension as keyof typeof colores]}20`,
        tension: 0.4,
        fill: false,
        pointRadius: 6,
        pointBackgroundColor: colores[dimension as keyof typeof colores],
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointHoverRadius: 8,
        spanGaps: true
      };
    }).filter(dataset => dataset.data.some(value => value !== null));

    return {
      labels,
      datasets
    };
  }
}