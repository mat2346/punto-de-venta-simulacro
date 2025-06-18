import { Component, Input, OnInit, ViewChild, ElementRef, OnDestroy } from '@angular/core';
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

@Component({
  selector: 'app-tutor-charts',
  standalone: true,
  imports: [],
  template: `
    <div class="space-y-8">
      
      <!-- Gráfica de Rendimiento por Materia -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-xl font-semibold mb-4 text-gray-800">Rendimiento por Materia</h3>
        <div class="relative w-full h-64 bg-gray-50 rounded-lg p-4">
          <canvas #barChart class="max-w-full max-h-full"></canvas>
        </div>
      </div>

      <!-- Gráficas de Asistencia y Participación -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        <!-- Gráfica de Asistencia -->
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-xl font-semibold mb-4 text-gray-800">Asistencia General</h3>
          <div class="relative h-64">
            <canvas #pieChart class="max-w-full max-h-full"></canvas>
          </div>
        </div>

        <!-- Tendencia de Notas -->
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-xl font-semibold mb-4 text-gray-800">Tendencia de Notas</h3>
          <div class="relative h-64">
            <canvas #lineChart class="max-w-full max-h-full"></canvas>
          </div>
        </div>

      </div>

      <!-- Gráfica de Progreso Mensual -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-xl font-semibold mb-4 text-gray-800">Progreso Mensual</h3>
        <div class="relative w-full h-64 bg-gray-50 rounded-lg p-4">
          <canvas #progressChart class="max-w-full max-h-full"></canvas>
        </div>
      </div>
      
    </div>
  `,
})
export class TutorChartsComponent implements OnInit, OnDestroy {
  @Input() datosRendimiento: any = {};
  
  @ViewChild('barChart', { static: true }) barChart!: ElementRef<HTMLCanvasElement>;
  @ViewChild('pieChart', { static: true }) pieChart!: ElementRef<HTMLCanvasElement>;
  @ViewChild('lineChart', { static: true }) lineChart!: ElementRef<HTMLCanvasElement>;
  @ViewChild('progressChart', { static: true }) progressChart!: ElementRef<HTMLCanvasElement>;

  private chartBar: Chart | null = null;
  private chartPie: Chart | null = null;
  private chartLine: Chart | null = null;
  private chartProgress: Chart | null = null;

  ngOnInit() {
    setTimeout(() => {
      this.crearGraficaBarras();
      this.crearGraficaPastel();
      this.crearGraficaLinea();
      this.crearGraficaProgreso();
    }, 100);
  }

  ngOnDestroy() {
    [this.chartBar, this.chartPie, this.chartLine, this.chartProgress].forEach(chart => {
      if (chart) chart.destroy();
    });
  }

  private crearGraficaBarras() {
    const ctx = this.barChart.nativeElement.getContext('2d');
    if (!ctx) return;

    const materias = this.datosRendimiento.materias || [];
    const labels = materias.map((m: any) => m.nombre);
    const notas = materias.map((m: any) => m.promedio);

    this.barChart.nativeElement.width = 800;
    this.barChart.nativeElement.height = 200;

    this.chartBar = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Promedio',
          data: notas,
          backgroundColor: ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#F97316'],
          borderColor: ['#2563EB', '#059669', '#D97706', '#DC2626', '#7C3AED', '#EA580C'],
          borderWidth: 2,
          borderRadius: 8,
          borderSkipped: false,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 4,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            titleColor: '#fff',
            bodyColor: '#fff',
            callbacks: {
              label: (context) => `Promedio: ${context.parsed.y}/100`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            grid: { color: 'rgba(0, 0, 0, 0.1)' },
            ticks: {
              callback: (value) => `${value}%`,
              font: { size: 11 }
            }
          },
          x: {
            grid: { display: false },
            ticks: { font: { size: 11 } }
          }
        }
      }
    });
  }

  private crearGraficaPastel() {
    const ctx = this.pieChart.nativeElement.getContext('2d');
    if (!ctx) return;

    const asistencia = this.datosRendimiento.asistencia || {};
    const presente = asistencia.presente || 18;
    const ausente = asistencia.ausente || 2;

    this.pieChart.nativeElement.width = 300;
    this.pieChart.nativeElement.height = 300;

    this.chartPie = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Presente', 'Ausente'],
        datasets: [{
          data: [presente, ausente],
          backgroundColor: ['#10B981', '#EF4444'],
          borderColor: ['#059669', '#DC2626'],
          borderWidth: 2,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 1,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              usePointStyle: true,
              font: { size: 12 }
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

    const tendencia = this.datosRendimiento.tendencia || [
      { fecha: '2025-05-01', promedio: 80 },
      { fecha: '2025-05-15', promedio: 83 },
      { fecha: '2025-06-01', promedio: 85 },
      { fecha: '2025-06-05', promedio: 87 }
    ];

    const labels = tendencia.map((t: any) => {
      const fecha = new Date(t.fecha);
      return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit' });
    });
    const notas = tendencia.map((t: any) => t.promedio);

    this.lineChart.nativeElement.width = 400;
    this.lineChart.nativeElement.height = 300;

    this.chartLine = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Promedio General',
          data: notas,
          borderColor: '#8B5CF6',
          backgroundColor: 'rgba(139, 92, 246, 0.1)',
          pointBackgroundColor: '#8B5CF6',
          pointBorderColor: '#7C3AED',
          pointRadius: 5,
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 1.3,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            grid: { color: 'rgba(0, 0, 0, 0.1)' },
            ticks: {
              callback: (value) => `${value}%`,
              font: { size: 10 }
            }
          },
          x: {
            grid: { color: 'rgba(0, 0, 0, 0.1)' },
            ticks: { font: { size: 10 } }
          }
        }
      }
    });
  }

  private crearGraficaProgreso() {
    const ctx = this.progressChart.nativeElement.getContext('2d');
    if (!ctx) return;

    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
    const promedios = [75, 78, 82, 85, 87, 85];
    const asistencia = [95, 92, 98, 96, 94, 97];

    this.progressChart.nativeElement.width = 800;
    this.progressChart.nativeElement.height = 200;

    this.chartProgress = new Chart(ctx, {
      type: 'line',
      data: {
        labels: meses,
        datasets: [
          {
            label: 'Promedio Académico',
            data: promedios,
            borderColor: '#3B82F6',
            pointBackgroundColor: '#3B82F6',
            pointRadius: 5,
            tension: 0.4,
            fill: false
          },
          {
            label: 'Asistencia (%)',
            data: asistencia,
            borderColor: '#10B981',
            pointBackgroundColor: '#10B981',
            pointRadius: 5,
            tension: 0.4,
            fill: false
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 4,
        plugins: {
          legend: {
            position: 'top',
            labels: {
              boxWidth: 12,
              font: { size: 12 },
              padding: 15
            }
          },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            titleColor: '#fff',
            bodyColor: '#fff',
            callbacks: {
              label: (context) => {
                const label = context.dataset.label || '';
                const value = context.parsed.y;
                return `${label}: ${value}${label.includes('Asistencia') ? '%' : '/100'}`;
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            grid: { color: 'rgba(0, 0, 0, 0.1)' },
            ticks: {
              callback: (value) => `${value}`,
              font: { size: 11 }
            }
          },
          x: {
            grid: { color: 'rgba(0, 0, 0, 0.1)' },
            ticks: { font: { size: 11 } }
          }
        }
      }
    });
  }
}