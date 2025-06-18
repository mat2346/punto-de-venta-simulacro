import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ProfesorService } from '../../../core/services/profesor.sevice';
import { CommonModule, NgFor, NgIf } from '@angular/common';

@Component({
  standalone: true,
  selector: 'app-reporte-asistencia',
  imports: [CommonModule, NgFor, NgIf],
  template: `
    <nav class="bg-indigo-600 p-4 text-white flex justify-between items-center sticky top-0 z-10">
      <button (click)="volver()" class="hover:bg-indigo-700 px-3 py-1 rounded">
        ← Volver
      </button>
      <h1 class="text-lg font-semibold">Reporte de Asistencia</h1>
      <div></div>
    </nav>

    <div class="overflow-auto max-w-full mt-6 p-6 bg-white rounded shadow">
      <table class="min-w-full border border-gray-300">
        <thead class="bg-gray-100">
          <tr>
            <th class="border px-4 py-2 sticky left-0 bg-gray-100 z-20">Estudiante</th>
            <th *ngFor="let fecha of fechas" class="border px-4 py-2 whitespace-nowrap text-center">
              {{ fecha }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let estudiante of estudiantes" class="hover:bg-gray-50">
            <td class="border px-4 py-2 sticky left-0 bg-white font-medium z-10">{{ estudiante.nombre }}</td>
            <td *ngFor="let presente of estudiante.asistencias" class="border px-4 py-2 text-center">
              <span *ngIf="presente" class="text-green-600 font-bold">✔️</span>
              <span *ngIf="!presente" class="text-red-600 font-bold">❌</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  `
})
export default class ReporteAsistenciaComponent implements OnInit {
  detalleId!: number;
  fechas: string[] = [];
  estudiantes: { nombre: string; asistencias: boolean[] }[] = [];

  constructor(private route: ActivatedRoute, private profesorService: ProfesorService) {}

  ngOnInit() {
    this.detalleId = Number(this.route.snapshot.paramMap.get('id'));
    this.profesorService.obtenerReporteAsistencia(this.detalleId).subscribe({
      next: (res) => {
        this.fechas = res.fechas;
        this.estudiantes = res.estudiantes;
      },
      error: (err) => {
        console.error('Error al cargar reporte de asistencia:', err);
      }
    });
  }

  volver() {
    window.history.back();
  }
}
