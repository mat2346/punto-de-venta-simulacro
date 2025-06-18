import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../../environments/environment';

@Component({
  standalone: true,
  selector: 'app-crear-actividad',
  imports: [CommonModule, HttpClientModule, FormsModule],
  template: `
    <div class="p-6 max-w-lg mx-auto bg-white rounded shadow mt-10">
      <h2 class="text-2xl font-bold mb-4">Crear Nueva Actividad</h2>
      <form (submit)="crearActividad(); $event.preventDefault()" class="space-y-4">
        <input
          type="text"
          [(ngModel)]="actividad.nombre"
          name="nombre"
          placeholder="Nombre de la actividad"
          required
          class="border p-2 rounded w-full"
        />

        <input
          type="text"
          [(ngModel)]="actividad.descripcion"
          name="descripcion"
          placeholder="Descripción (opcional)"
          class="border p-2 rounded w-full"
        />

        <input
          type="number"
          [(ngModel)]="actividad.dimension"
          name="dimension"
          placeholder="ID de la dimensión"
          required
          class="border p-2 rounded w-full"
        />

        <div class="flex justify-between">
          <button
            type="button"
            (click)="volver()"
            class="px-4 py-2 border rounded hover:bg-gray-100"
          >
            Cancelar
          </button>
          <button
            type="submit"
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Crear
          </button>
        </div>
      </form>
    </div>
  `,
})
export class CrearActividadComponent {
  detalleId!: number;
  actividad = {
    nombre: '',
    descripcion: '',
    dimension: null,
  };

  constructor(
    private route: ActivatedRoute,
    private http: HttpClient,
    private router: Router
  ) {
    this.detalleId = +this.route.snapshot.paramMap.get('id')!;
  }

  crearActividad() {
    const token = localStorage.getItem('access_token');
    const headers = { Authorization: `Bearer ${token}` };

    this.http
      .post(environment.apiUrl + `api/actividades/`, this.actividad, { headers })
      .subscribe({
        next: () => {
          alert('Actividad creada correctamente');
          this.router.navigate(['/profesor/materia', this.detalleId]);
        },
        error: (err) => {
          console.error('Error al crear actividad:', err);
          alert('Error al crear actividad, revisa la consola.');
        },
      });
  }

  volver() {
    this.router.navigate(['/profesor/materia', this.detalleId]);
  }
}
