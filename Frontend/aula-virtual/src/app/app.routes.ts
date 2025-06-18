import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { roleGuard } from './core/guards/role.guard';
import { AlumnoHistorialMateriasComponent } from './modules/dashboard/pages/alumno-historial-materias.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },

  {
    path: 'login',
    loadComponent: () =>
      import('./modules/auth/pages/login/login.component').then((m) => m.default),
  },

  {
    path: 'profesor',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/profesor-dashboard.component').then(m => m.ProfesorDashboardComponent)
  },
  {
    path: 'profesor/materia/:id',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/materia-detalle.component').then(m => m.MateriaDetalleComponent)
  },
  {
    path: 'mi-rendimiento',
    canActivate: [authGuard, roleGuard(['estudiante'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/alumno-dashboard.component').then(m => m.AlumnoDashboardComponent)
  },
  {
    path: 'mi-rendimiento/materia/:id',
    canActivate: [authGuard, roleGuard(['estudiante'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/alumno-materia-detalle.component').then(m => m.AlumnoMateriaDetalleComponent)
  },
  {
    path: 'mi-hijo',
    canActivate: [authGuard, roleGuard(['tutor'])],
    loadComponent: () => import('./modules/dashboard/pages/tutor-dashboard.component').then(m => m.TutorDashboardComponent),
  },
  {
    path: 'profesor/materia/:id/asistencia',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/asistencia.component').then(m => m.default)
  },
  {
    path: 'profesor/materia/:id/reporte-asistencia',
    loadComponent: () =>
      import('./modules/dashboard/pages/reporte-asistencia.component').then(m => m.default),
    canActivate: [authGuard, roleGuard(['profesor'])]
  },
  {
    path: 'profesor/materia/:id/crear-actividad',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/crear-actividad.component').then(m => m.CrearActividadComponent),
  },
  {
    path: 'profesor/materia/:id/actividad/:actividadId/calificar',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/calificar-actividad.component').then(m => m.CalificarActividadComponent)
  },
  {
    path: 'profesor/materia/:id/reporte-entregas',
    canActivate: [authGuard, roleGuard(['profesor'])],
    loadComponent: () =>
      import('./modules/dashboard/pages/reporte-entregas.component').then(m => m.ReporteEntregasComponent)
  }
  ,
  {
   path: 'no-autorizado',
   loadComponent: () => import('./shared/pages/no-autorizado.component').then(m => m.NoAutorizadoComponent)
  },
  {
    path: 'mi-rendimiento/historial',
    component: AlumnoHistorialMateriasComponent,
    canActivate: [authGuard]
  }

];

