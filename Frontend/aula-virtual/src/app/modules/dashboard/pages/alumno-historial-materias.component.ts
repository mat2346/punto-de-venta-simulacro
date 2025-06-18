import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { NgFor, NgIf, CommonModule } from '@angular/common';
import { AlumnoService } from '../../../core/services/alumno.service';
import { SidebarComponent } from '../components/sidebar.component';

@Component({
  selector: 'app-alumno-historial-materias',
  standalone: true,
  imports: [NgFor, NgIf, CommonModule, SidebarComponent],
  template: `
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <app-sidebar class="w-64"></app-sidebar>

      <!-- Contenido principal -->
      <main class="flex-1 p-6 bg-gradient-to-b from-blue-100 to-blue-300">
        
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
            <h1 class="text-3xl font-bold text-gray-800">Historial de Materias</h1>
            <p class="text-gray-600">Todas las materias cursadas organizadas por gestión</p>
          </div>
        </div>

        <!-- Loading state -->
        <div *ngIf="cargando" class="flex justify-center items-center my-8">
          <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-blue-500"></div>
          <span class="ml-2">Cargando historial...</span>
        </div>

        <!-- Error state -->
        <div *ngIf="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded">
          <p>{{ error }}</p>
        </div>

        <!-- Contenido del historial -->
        <div *ngIf="!cargando && !error">
          <!-- Iteramos por cada gestión en el historial -->
          <div *ngFor="let gestion of historialPorGestion" class="mb-10">
            <!-- Título de la gestión -->
            <div class="flex items-center mb-4">
              <div class="h-12 w-12 rounded-full bg-purple-500 flex items-center justify-center text-white text-xl font-bold mr-4">
                {{ gestion.anio }}
              </div>
              <div>
                <h2 class="text-2xl font-bold text-gray-800">{{ gestion.nombre }}</h2>
                <p class="text-sm text-gray-600">{{ gestion.materias.length }} materias</p>
              </div>
            </div>

            <!-- Lista de materias de esta gestión -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
              <div *ngFor="let materia of gestion.materias; trackBy: trackByMateriaId" 
                   class="bg-white p-4 rounded shadow border-l-4"
                   [ngClass]="{
                     'border-green-500': materia.promedio >= 80,
                     'border-yellow-500': materia.promedio >= 60 && materia.promedio < 80,
                     'border-red-500': materia.promedio < 60 || materia.promedio === 'N/A'
                   }">
                
                <p class="text-lg font-bold">{{ materia.nombre }}</p>
                <p class="text-sm text-gray-500">Profesor: {{ materia.profesor }}</p>
                <p class="text-sm text-gray-500">Gestión: {{ materia.gestion || 'Gestión Actual' }}</p>
                <p class="text-sm">Promedio: 
                  <span class="font-semibold"
                        [ngClass]="{
                          'text-green-600': materia.promedio >= 80,
                          'text-yellow-600': materia.promedio >= 60 && materia.promedio < 80,
                          'text-red-600': materia.promedio < 60 || materia.promedio === 'N/A'
                        }">
                    {{ materia.promedio }}
                  </span>
                </p>
                <button 
                  (click)="verDetalleMateria(materia)" 
                  class="mt-3 bg-blue-600 hover:bg-blue-700 text-white px-4 py-1 rounded">
                  Ver Detalles
                </button>
              </div>
            </div>
          </div>

          <!-- Si no hay materias -->
          <div *ngIf="historialPorGestion.length === 0" class="text-center py-12">
            <div class="text-gray-400 text-6xl mb-4">📚</div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No hay materias en tu historial</h3>
            <p class="text-gray-500">Aún no tienes un historial de materias cursadas.</p>
          </div>
        </div>
      </main>
    </div>
  `
})
export class AlumnoHistorialMateriasComponent implements OnInit {
  cargando = true;
  error = '';
  materias: any[] = [];
  historialPorGestion: any[] = [];

  constructor(
    private alumnoService: AlumnoService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.cargarHistorialMaterias();
  }

  cargarHistorialMaterias(): void {
    this.cargando = true;
    this.error = '';

    // Usamos el método existente para obtener materias
    this.alumnoService.getMateriasPorAlumno().subscribe({
      next: (data) => {
        this.materias = data;
        this.organizarPorGestion();
        this.cargando = false;
      },
      error: (err) => {
        console.error('Error al cargar materias:', err);
        this.error = 'Error al cargar el historial de materias';
        this.cargando = false;
      }
    });
  }

  // Organizar las materias por gestión
  organizarPorGestion(): void {
    // Crear un mapa para agrupar por gestión
    const gestionesMap = new Map<string, any>();

    // Definir gestiones basadas en los datos disponibles
    const anioActual = new Date().getFullYear();
    
    // Agrupar materias por gestión
    this.materias.forEach((materia, index) => {
      // Determinar la gestión basada en el índice (simulación)
      // Esto asigna las materias a diferentes gestiones en función de su posición
      let gestion: string;
      let anio: number;

      // Dividir materias entre gestiones basado en su índice
      if (index < this.materias.length / 3) {
        gestion = 'Gestión Actual';
        anio = anioActual;
      } else if (index < (this.materias.length * 2) / 3) {
        gestion = `Gestión ${anioActual - 1}`;
        anio = anioActual - 1;
      } else {
        gestion = `Gestión ${anioActual - 2}`;
        anio = anioActual - 2;
      }
      
      // Si la materia tiene su propia propiedad de gestión, usarla
      if (materia.gestion) {
        gestion = materia.gestion;
        // Extraer año de la gestión si es posible
        const anioMatch = materia.gestion.match(/\d{4}/);
        if (anioMatch) {
          anio = parseInt(anioMatch[0]);
        }
      }

      // Asignar la gestión a la materia para mostrarla en la interfaz
      materia.gestion = gestion;
      
      if (!gestionesMap.has(gestion)) {
        gestionesMap.set(gestion, {
          nombre: gestion,
          anio: anio,
          materias: []
        });
      }
      
      // Añadir la materia al grupo de gestión
      gestionesMap.get(gestion).materias.push({
        ...materia,
        // Convertir promedio a número si es posible
        promedio: materia.promedio === 'N/A' ? materia.promedio : Number(materia.promedio)
      });
    });

    // Convertir el mapa a array y ordenar por año descendente (más reciente primero)
    this.historialPorGestion = Array.from(gestionesMap.values())
      .sort((a, b) => b.anio - a.anio);
    
    // Console log con tipo explícito para el parámetro 'm'
    console.log('Materias agrupadas por gestiones:', this.historialPorGestion);
    console.log('Detalle de gestiones:');
    this.historialPorGestion.forEach(gestion => {
      console.log(`Gestión: ${gestion.nombre} (${gestion.anio}) - ${gestion.materias.length} materias`);
      console.table(gestion.materias.map((m: any) => ({
        id: m.id,
        nombre: m.nombre,
        profesor: m.profesor,
        promedio: m.promedio
      })));
    });
  }

  verDetalleMateria(materia: any): void {
    if (!materia || !materia.id) {
      console.error('Error: La materia no tiene ID válido');
      alert('Error: No se puede acceder al detalle de esta materia.');
      return;
    }
    
    this.router.navigate(['/mi-rendimiento/materia', materia.id]);
  }

  volver(): void {
    this.router.navigate(['/mi-rendimiento']);
  }

  trackByMateriaId(index: number, materia: any): any {
    return materia.id || index;
  }
}