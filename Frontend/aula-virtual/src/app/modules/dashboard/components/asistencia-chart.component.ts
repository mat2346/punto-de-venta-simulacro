import { Component, Input, OnInit, ViewChild, ElementRef } from '@angular/core';
import { Chart, registerables } from 'chart.js';

// Registrar todos los componentes necesarios de Chart.js
Chart.register(...registerables);

@Component({
  selector: 'app-asistencia-chart',
  standalone: true,
  template: `
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-semibold mb-4 text-gray-800">{{ titulo }}</h3>
      
      <!-- Gráfica de Dona -->
      <div class="flex flex-col lg:flex-row items-center gap-6 mb-8">
        <div class="w-full lg:w-1/2">
          <!-- 👈 Contenedor con altura fija para la dona -->
          <div class="relative h-80 w-full">
            <canvas #donutChart class="max-w-full max-h-full"></canvas>
          </div>
        </div>
        
        <!-- Estadísticas -->
        <div class="w-full lg:w-1/2 space-y-4">
          <div class="flex justify-between items-center p-3 bg-green-50 rounded-lg">
            <span class="text-green-700 font-medium">Clases Asistidas</span>
            <span class="text-2xl font-bold text-green-600">{{ datosAsistencia.clases_asistidas }}</span>
          </div>
          
          <div class="flex justify-between items-center p-3 bg-red-50 rounded-lg">
            <span class="text-red-700 font-medium">Clases Perdidas</span>
            <span class="text-2xl font-bold text-red-600">{{ datosAsistencia.clases_perdidas }}</span>
          </div>
          
          <div class="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
            <span class="text-blue-700 font-medium">Total de Clases</span>
            <span class="text-2xl font-bold text-blue-600">{{ datosAsistencia.total_clases }}</span>
          </div>
          
          <div class="flex justify-between items-center p-4 bg-gray-50 rounded-lg border-l-4"
               [class]="getPorcentajeClass()">
            <span class="font-semibold">Porcentaje General</span>
            <span class="text-3xl font-bold">{{ datosAsistencia.porcentaje }}%</span>
          </div>
        </div>
      </div>
      
      <!-- Gráfica de Línea - Tendencia -->
      <div class="border-t border-gray-200 pt-6">
        <h4 class="text-lg font-semibold mb-4 text-gray-700">Tendencia de Asistencia</h4>
        <!-- 👈 Contenedor con altura fija y controlada -->
        <div class="relative w-full h-64 bg-gray-50 rounded-lg p-4">
          <canvas #lineChart class="max-w-full max-h-full"></canvas>
        </div>
      </div>
    </div>
  `,
})
export class AsistenciaChartComponent implements OnInit {
  @Input() datosAsistencia: any = {};
  @Input() titulo: string = 'Análisis de Asistencia';
  
  @ViewChild('donutChart', { static: true }) donutChart!: ElementRef<HTMLCanvasElement>;
  @ViewChild('lineChart', { static: true }) lineChart!: ElementRef<HTMLCanvasElement>;

  private chartDonut: Chart | null = null;
  private chartLine: Chart | null = null;

  ngOnInit() {
    setTimeout(() => {
      this.crearGraficaDona();
      this.crearGraficaLinea();
    }, 100);
  }

  ngOnDestroy() {
    if (this.chartDonut) {
      this.chartDonut.destroy();
    }
    if (this.chartLine) {
      this.chartLine.destroy();
    }
  }

  getPorcentajeClass(): string {
    const porcentaje = this.datosAsistencia.porcentaje || 0;
    if (porcentaje >= 80) return 'border-green-500';
    if (porcentaje >= 60) return 'border-yellow-500';
    return 'border-red-500';
  }

  private crearGraficaDona() {
    const ctx = this.donutChart.nativeElement.getContext('2d');
    if (!ctx) return;

    const asistidas = this.datosAsistencia.clases_asistidas || 0;
    const perdidas = this.datosAsistencia.clases_perdidas || 0;

    // 👈 Ajustar tamaño del canvas
    this.donutChart.nativeElement.width = 300;
    this.donutChart.nativeElement.height = 300;

    this.chartDonut = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Clases Asistidas', 'Clases Perdidas'],
        datasets: [{
          data: [asistidas, perdidas],
          backgroundColor: [
            '#10B981', // Verde
            '#EF4444'  // Rojo
          ],
          borderColor: [
            '#059669',
            '#DC2626'
          ],
          borderWidth: 2,
          hoverBackgroundColor: [
            '#059669',
            '#DC2626'
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true, // 👈 Mantener aspecto
        aspectRatio: 1, // 👈 Proporción cuadrada
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              usePointStyle: true,
              font: {
                size: 12
              }
            }
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                const total = asistidas + perdidas;
                const porcentaje = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                return `${context.label}: ${context.parsed} (${porcentaje}%)`;
              }
            }
          }
        },
        cutout: '60%'
      }
    });
  }

  private crearGraficaLinea() {
    const ctx = this.lineChart.nativeElement.getContext('2d');
    if (!ctx) return;

    // 👈 Establecer tamaño fijo del canvas
    this.lineChart.nativeElement.width = 800;
    this.lineChart.nativeElement.height = 200;

    // Procesar historial para la gráfica de línea
    const historial = this.datosAsistencia.historial_semanal || [];
    
    // 👈 Limitar a últimos 10 registros para evitar que se haga muy ancha
    const historialLimitado = historial.slice(-10);
    
    const labels = historialLimitado.map((item: any) => item.fecha);
    const asistenciaData = historialLimitado.map((item: any) => item.presente ? 1 : 0);

    // Calcular promedio móvil para mostrar tendencia
    const promedioMovil = this.calcularPromedioMovil(asistenciaData, 3);

    this.chartLine = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Asistencia',
            data: asistenciaData,
            borderColor: '#3B82F6',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            pointBackgroundColor: asistenciaData.map((val: number) => val === 1 ? '#10B981' : '#EF4444'),
            pointBorderColor: asistenciaData.map((val: number) => val === 1 ? '#059669' : '#DC2626'),
            pointRadius: 5,
            pointHoverRadius: 7,
            tension: 0.3,
            fill: true
          },
          {
            label: 'Tendencia',
            data: promedioMovil,
            borderColor: '#F59E0B',
            backgroundColor: 'transparent',
            borderDash: [5, 5],
            pointRadius: 0,
            tension: 0.3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true, // 👈 Mantener proporción
        aspectRatio: 4, // 👈 Proporción 4:1 (ancho:alto)
        interaction: {
          intersect: false,
          mode: 'index'
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Fechas Recientes',
              font: {
                size: 12
              }
            },
            grid: {
              display: true,
              color: 'rgba(0, 0, 0, 0.1)'
            },
            ticks: {
              maxTicksLimit: 8, // 👈 Limitar número de etiquetas
              font: {
                size: 10
              }
            }
          },
          y: {
            title: {
              display: true,
              text: 'Asistencia',
              font: {
                size: 12
              }
            },
            min: 0,
            max: 1,
            grid: {
              display: true,
              color: 'rgba(0, 0, 0, 0.1)'
            },
            ticks: {
              stepSize: 0.5,
              callback: (value) => {
                if (value === 1) return 'Presente';
                if (value === 0.5) return '50%';
                if (value === 0) return 'Ausente';
                return '';
              },
              font: {
                size: 10
              }
            }
          }
        },
        plugins: {
          legend: {
            position: 'top',
            labels: {
              boxWidth: 12,
              font: {
                size: 12
              },
              padding: 15
            }
          },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            titleColor: '#fff',
            bodyColor: '#fff',
            borderColor: '#3B82F6',
            borderWidth: 1,
            callbacks: {
              label: (context) => {
                if (context.datasetIndex === 0) {
                  return `Asistencia: ${context.parsed.y === 1 ? 'Presente' : 'Ausente'}`;
                }
                return `Tendencia: ${(context.parsed.y * 100).toFixed(1)}%`;
              }
            }
          }
        }
      }
    });
  }

  private calcularPromedioMovil(datos: number[], ventana: number): number[] {
    const resultado: number[] = [];
    for (let i = 0; i < datos.length; i++) {
      const inicio = Math.max(0, i - ventana + 1);
      const fin = i + 1;
      const segmento = datos.slice(inicio, fin);
      const promedio = segmento.reduce((a, b) => a + b, 0) / segmento.length;
      resultado.push(promedio);
    }
    return resultado;
  }
}