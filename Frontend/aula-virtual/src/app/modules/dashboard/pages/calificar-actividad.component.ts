import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../../environments/environment';

@Component({
  standalone: true,
  selector: 'app-calificar-actividad',
  imports: [CommonModule, HttpClientModule, FormsModule],
  template: `
    <div class="p-6 max-w-4xl mx-auto bg-white rounded shadow">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold">Calificar Entregas</h2>
        <button
          (click)="volver()"
          class="px-4 py-2 border rounded hover:bg-gray-100"
        >
          ← Volver
        </button>
      </div>

      <table class="w-full border-collapse border border-gray-300 mb-4">
        <thead>
          <tr class="bg-gray-100">
            <th class="border border-gray-300 p-2">Estudiante</th>
            <th class="border border-gray-300 p-2 text-center">Entregado</th>
            <th class="border border-gray-300 p-2 text-center">Calificación</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let e of entregas">
            <td class="border border-gray-300 p-2">{{ e.nombreEstudiante }}</td>
            <td class="border border-gray-300 p-2 text-center">
              <input type="checkbox" [(ngModel)]="e.entregado" />
            </td>
            <td class="border border-gray-300 p-2 text-center">
              <input
                type="number"
                [(ngModel)]="e.calificacion"
                [disabled]="!e.entregado"
                min="0" max="100"
                class="w-20 p-1 border rounded"
              />
            </td>
          </tr>
        </tbody>
      </table>

      <button
        class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        (click)="guardarCalificaciones()"
      >
        Guardar Calificaciones
      </button>
    </div>
  `
})
export class CalificarActividadComponent implements OnInit {
  detalleId!: number;
  actividadId!: number;
  entregas: {
    usuario: number;
    nombreEstudiante: string;
    entregado: boolean;
    calificacion: number | null;
  }[] = [];

  constructor(private route: ActivatedRoute, private http: HttpClient) {}

  ngOnInit(): void {
    this.detalleId = +this.route.snapshot.paramMap.get('id')!;
    this.actividadId = +this.route.snapshot.paramMap.get('actividadId')!;
    this.cargarEntregas();
  }

  cargarEntregas() {
    const token = localStorage.getItem('access_token');
    const headers = { Authorization: `Bearer ${token}` };

    this.http
      .get<any[]>(environment.apiUrl + `api/profesor/materia/${this.detalleId}/actividad/${this.actividadId}/entregas/`, { headers })
      .subscribe({
        next: (data) => {
          this.entregas = data.map(e => ({
            usuario: e.usuario,
            nombreEstudiante: e.nombreEstudiante || 'Estudiante',
            entregado: e.entregado,
            calificacion: e.calificacion
          }));
        },
        error: (err) => {
          console.error('Error al cargar entregas:', err);
        }
      });
  }

  guardarCalificaciones() {
    const token = localStorage.getItem('access_token');
    const headers = { Authorization: `Bearer ${token}` };

    const payload = this.entregas.map(e => ({
      usuario_id: e.usuario,
      entregado: e.entregado,
      calificacion: e.entregado ? e.calificacion : null,
    }));

    this.http
      .post(environment.apiUrl + `api/actividades/${this.actividadId}/registrar-entregas/`, payload, { headers })
      .subscribe({
        next: () => alert('Calificaciones guardadas correctamente'),
        error: (err) => console.error('Error al guardar calificaciones:', err),
      });
  }

  volver() {
    window.history.back();
  }
}
