import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { SidebarComponent } from '../components/sidebar.component';
import { NgIf, NgFor } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-materia-detalle',
  imports: [CommonModule, HttpClientModule, SidebarComponent, NgIf, NgFor,RouterModule],
  template: `
    <div class="flex min-h-screen">
      <app-sidebar></app-sidebar>
      <div class="flex-1 p-6 bg-gray-50">

        <div class="flex justify-between items-center mb-6">
          <h1 class="text-2xl font-bold text-slate-800">Detalle de la Materia</h1>

          <div class="flex space-x-2">
            <button
              class="text-sm px-3 py-1 border rounded text-blue-600 border-blue-600 hover:bg-blue-100"
              (click)="volver()"
            >
              ← Volver
            </button>

            <a
              [routerLink]="['/profesor/materia', detalleId, 'asistencia']"
              class="text-sm px-3 py-1 rounded bg-indigo-600 text-white hover:bg-indigo-700"
            >
              Tomar asistencia
            </a>

            <a
              [routerLink]="['/profesor/materia', detalleId, 'reporte-asistencia']"
              class="ml-2 bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
            >
              Ver reporte asistencia
            </a>
          </div>
        </div>

        <p class="text-gray-600 mb-4">ID del detalle materia: <strong>{{ detalleId }}</strong></p>

        <!-- Tabla estudiantes -->
        <div class="bg-white rounded shadow overflow-hidden mb-8">
          <table class="w-full text-left table-auto">
            <thead class="bg-gray-100 text-slate-700 font-semibold">
              <tr>
                <th class="p-3">Nombre</th>
                <th class="p-3">ID</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let est of estudiantes" class="border-b hover:bg-gray-50">
                <td class="p-3">{{ est.nombre }}</td>
                <td class="p-3">{{ est.id }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Listado actividades -->
        <div class="bg-white rounded shadow p-6">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold text-slate-700">Actividades</h2>
            <button class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
              (click)="irACrearActividad()"
            >
              Crear Actividad
            </button>
            <button class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700" (click)="irAReporteEntregas()">
              Ver Reporte Entregas
             </button>
          </div>

          <div *ngIf="actividades.length > 0" class="space-y-2">
            <div *ngFor="let act of actividades" class="bg-gray-50 shadow-sm p-4 rounded border cursor-pointer"
                 (click)="irACalificar(act.id)">
              <h3 class="font-semibold text-slate-800">{{ act.nombre }}</h3>
              <p class="text-slate-600 text-sm">{{ act.descripcion }}</p>
              <p class="text-slate-400 text-xs">Fecha: {{ act.fechaCreacion }}</p>
            </div>
          </div>
          <p *ngIf="actividades.length === 0" class="text-gray-500">No hay actividades asignadas.</p>
        </div>

      </div>
    </div>
  `
})
export class MateriaDetalleComponent implements OnInit {
  detalleId!: number;
  estudiantes: any[] = [];
  actividades: any[] = [];

  constructor(private route: ActivatedRoute, private http: HttpClient, private router: Router) {}

  ngOnInit(): void {
    this.detalleId = Number(this.route.snapshot.paramMap.get('id'));
    this.cargarEstudiantes();
    this.cargarActividades();
  }

  cargarEstudiantes(): void {
    const token = localStorage.getItem('access_token');
    const headers = { Authorization: `Bearer ${token}` };

    this.http
      .get<any[]>(environment.apiUrl + `api/profesor/materia/${this.detalleId}/estudiantes/`, { headers })
      .subscribe({
        next: (data) => {
          this.estudiantes = data;
        },
        error: (err) => {
          console.error('Error al obtener estudiantes:', err);
        }
      });
  }

  cargarActividades(): void {
    const token = localStorage.getItem('access_token');
    const headers = { Authorization: `Bearer ${token}` };

    this.http
      .get<any[]>(environment.apiUrl + `api/profesor/materia/${this.detalleId}/actividades/`, { headers })
      .subscribe({
        next: (data) => {
          this.actividades = data;
        },
        error: (err) => {
          console.error('Error al obtener actividades:', err);
        }
      });
  }

  irACrearActividad() {
    this.router.navigate(['/profesor/materia', this.detalleId, 'crear-actividad']);
  }

  irACalificar(actividadId: number) {
    this.router.navigate(['/profesor/materia', this.detalleId, 'actividad', actividadId, 'calificar']);
  }
  irAReporteEntregas() {
  this.router.navigate(['/profesor/materia', this.detalleId, 'reporte-entregas']);
  }

  volver() {
    window.history.back();
  }
}
