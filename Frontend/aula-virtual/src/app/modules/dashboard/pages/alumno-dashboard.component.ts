import { Component, OnInit } from '@angular/core';
import { NgFor, NgClass, NgIf } from '@angular/common'; // 👈 Agregar NgIf
import { AlumnoService } from '../../../core/services/alumno.service';
import { SidebarComponent } from '../components/sidebar.component';
import { Router } from '@angular/router';

@Component({
  selector: 'app-alumno-dashboard',
  standalone: true,
  imports: [NgFor, NgClass, NgIf, SidebarComponent], // 👈 Incluir NgIf
  template: `
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <app-sidebar class="w-64"></app-sidebar>

      <!-- Contenido principal -->
      <main class="flex-1 p-6 bg-gradient-to-b from-blue-100 to-blue-300 overflow-auto">

        <h2 class="text-2xl font-bold mb-6">Bienvenido, Alumno</h2>

        <!-- Resumen en tarjetas -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <!-- Tarjetas existentes... -->
          <div class="bg-white p-4 rounded shadow">
            <p class="text-gray-500">Promedio actual</p>
            <p class="text-2xl font-bold text-blue-600">{{ resumen.promedio }}</p>
          </div>
          <div class="bg-white p-4 rounded shadow">
            <p class="text-gray-500">Asistencia</p>
            <p class="text-2xl font-bold text-green-600">{{ resumen.asistencia }}%</p>
          </div>
          <div class="bg-white p-4 rounded shadow">
            <p class="text-gray-500">Participación</p>
            <p class="text-2xl font-bold text-yellow-500">{{ resumen.participacion }}%</p>
          </div>
          <div class="bg-white p-4 rounded shadow">
            <p class="text-gray-500">Predicción</p>
            <p class="text-2xl font-bold text-purple-600">{{ resumen.prediccion }}</p>
          </div>
        </div>

        <!-- Botón de Historial de Materias -->
        <div class="flex justify-end mb-4">
          <button 
            (click)="verHistorialMaterias()" 
            class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg flex items-center">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            Historial de Materias
          </button>
        </div>

        <!-- Loading state -->
        <div *ngIf="cargando" class="flex justify-center items-center my-8">
          <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-blue-500"></div>
          <span class="ml-2">Cargando materias...</span>
        </div>

        <!-- Error state -->
        <div *ngIf="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded">
          <p>{{ error }}</p>
        </div>

        <!-- Materias actuales (existente) -->
        <div *ngIf="!cargando">
          <h3 class="text-xl font-semibold mb-2">Materias actuales</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            <div *ngFor="let materia of materias; trackBy: trackByMateriaId" class="bg-white p-4 rounded shadow">
              <!-- Debug: Mostrar ID -->
              <div class="text-xs text-gray-400 mb-1">ID: {{ materia.id || 'SIN ID' }}</div>
              
              <p class="text-lg font-bold">{{ materia.nombre }}</p>
              <p class="text-sm text-gray-500">Profesor: {{ materia.profesor }}</p>
              <p class="text-sm">Promedio: <span class="text-blue-600 font-semibold">{{ materia.promedio }}</span></p>
              <button 
                (click)="verDetalleMateria(materia)" 
                class="mt-3 bg-blue-600 hover:bg-blue-700 text-white px-4 py-1 rounded">
                Ver Detalles
              </button>
            </div>
          </div>
        </div>

        <!-- Actividades -->
        <div *ngIf="!cargando">
          <h3 class="text-xl font-semibold mb-2">Actividades recientes</h3>
          <div class="bg-white rounded shadow p-4">
            <div *ngIf="actividades.length === 0" class="text-center py-4 text-gray-500">
              No hay actividades recientes
            </div>
            <table *ngIf="actividades.length > 0" class="w-full table-auto">
              <thead>
                <tr class="text-left border-b">
                  <th class="py-2">Materia</th>
                  <th>Título</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let actividad of actividades" class="border-b hover:bg-gray-50">
                  <td class="py-2">{{ actividad.materia }}</td>
                  <td>{{ actividad.titulo }}</td>
                  <td>
                    <span [ngClass]="{
                      'text-green-600': actividad.estado === 'Entregado',
                      'text-yellow-500': actividad.estado === 'Pendiente'
                    }">{{ actividad.estado }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

      </main>
    </div>
  `,
})
export class AlumnoDashboardComponent implements OnInit {

  resumen = {
    promedio: 'N/A',
    asistencia: 0,
    participacion: 0,
    prediccion: 'N/A'
  };

  materias: any[] = [];
  actividades: any[] = [];
  cargando = true;
  error = '';

  constructor(
    private alumnoService: AlumnoService,
    private router: Router
  ) {}

  ngOnInit() {
    this.cargarDatos();
  }

  cargarDatos() {
    this.cargando = true;
    this.error = '';

    // 👈 Intentar cargar resumen primero
    this.alumnoService.getResumenDashboard().subscribe({
      next: (data) => {
        console.log('Resumen recibido:', data);
        this.procesarResumen(data);
        this.cargando = false;
      },
      error: (err) => {
        console.error('Error al cargar resumen:', err);
        // Si falla el resumen, cargar solo materias
        this.cargarSoloMaterias();
      }
    });
  }

  procesarResumen(data: any) {
    // Procesar resumen
    this.resumen = {
      promedio: data.promedio || 'N/A',
      asistencia: data.porcentaje_asistencia || 0,
      participacion: data.porcentaje_participacion || 0,
      prediccion: data.prediccion || 'N/A'
    };

    // 👈 Procesar materias conservando ID
    const mappedMaterias = data.materias.map((m: any) => ({
      id: m.id,
      nombre: m.nombre,
      profesor: m.profesor,
      promedio: m.promedio || 'N/A'
    }));
    this.materias = this.filterLastUniqueSubjects(mappedMaterias);

    // Procesar actividades
    this.actividades = data.actividades_recientes || [];
  }

  cargarSoloMaterias() {
    this.alumnoService.getMateriasPorAlumno().subscribe({
      next: (materias) => {
        console.log('Materias recibidas desde backend:', materias);
        
        // 👈 Ya no necesitas mapear porque el backend devuelve la estructura correcta
        const mappedMaterias = materias.map((m: any) => {
          console.log('Procesando materia:', m);
          
          // Verificar que tiene ID
          if (!m.id) {
            console.error('❌ Materia sin ID:', m);
          }
          
          return {
            id: m.id,
            nombre: m.nombre,
            profesor: m.profesor,
            promedio: m.promedio || 'N/A'
          };
        });
        this.materias = this.filterLastUniqueSubjects(mappedMaterias);
        
        console.log('Materias procesadas para frontend:', this.materias);
        this.cargando = false;
      },
      error: (err) => {
        console.error('Error al cargar materias:', err);
        this.error = 'Error al cargar las materias';
        this.cargando = false;
      }
    });
  }

  verDetalleMateria(materia: any): void {
    console.log('=== DEBUG NAVEGACIÓN ===');
    console.log('Materia completa:', materia);
    console.log('ID de materia:', materia.id);
    
    if (!materia || !materia.id) {
      console.error('❌ Error: La materia no tiene ID válido');
      alert('Error: No se puede acceder al detalle de esta materia. ID faltante.');
      return;
    }

    console.log('✅ Navegando a:', `/mi-rendimiento/materia/${materia.id}`);
    this.router.navigate(['/mi-rendimiento/materia', materia.id]);
  }

  verHistorialMaterias(): void {
    this.router.navigate(['/mi-rendimiento/historial']);
  }

  trackByMateriaId(index: number, materia: any): any {
    return materia.id || index;
  }

  // Add this method inside the AlumnoDashboardComponent class
  filterLastUniqueSubjects(subjects: any[]): any[] {
    // Use a Map to track the latest occurrence of each ID
    const subjectMap = new Map<number, any>();
    
    // Loop through subjects and keep the latest occurrence of each ID
    for (const subject of subjects) {
      subjectMap.set(subject.id, subject);
    }
    
    // Convert Map values to array
    const uniqueSubjects = Array.from(subjectMap.values());
    
    // Return only the last 10 (or fewer if there are less than 10)
    return uniqueSubjects.slice(Math.max(0, uniqueSubjects.length - 10));
  }
}

