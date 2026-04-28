# APP_GYM

Aplicación iOS para rutinas, entrenamientos y seguimiento de progreso, hecha con SwiftUI.

**Repositorio:** [github.com/joseraulsoriano/repo-swift-free-gym](https://github.com/joseraulsoriano/repo-swift-free-gym)

## Cómo se ve la app

Las capturas del README viven en el catálogo **Assets** del proyecto (image sets), para que uses los mismos archivos en Xcode y en GitHub.

### Vista principal (catálogo Assets)

![Vista APP_GYM](APP_GYM/Assets.xcassets/ReadmeShowcase.imageset/readme-showcase.png)

Para añadir más pantallas: en Xcode crea otro **Image Set** dentro de `APP_GYM/Assets.xcassets/` (por ejemplo `ReadmeLogin.imageset`), arrastra ahí tus PNG y enlázalos en este README con la misma ruta relativa, por ejemplo:

```markdown
![Login](APP_GYM/Assets.xcassets/ReadmeLogin.imageset/login.png)
```

GitHub solo muestra la imagen si el PNG está versionado en el repositorio con ese nombre y ruta.

## Descripción

Gestión de sesiones de gimnasio, rutinas, objetivos, métricas corporales y recordatorios. Persistencia en JSON local y, con la configuración adecuada, Core Data con CloudKit.

## Requisitos

- iOS 18.0 o superior (target del proyecto)
- Xcode 16 o superior recomendado
- Swift 5

## Clonar y abrir

```bash
git clone https://github.com/joseraulsoriano/repo-swift-free-gym.git
cd repo-swift-free-gym
open APP_GYM.xcodeproj
```

En **Signing & Capabilities**, asigna tu **Team**. Luego compila y ejecuta en simulador o dispositivo.

## Estructura principal

```
repo-swift-free-gym/
├── APP_GYM/
│   ├── CoreData/
│   ├── Domain/
│   ├── Views/
│   ├── Widgets/
│   └── Assets.xcassets/     # Incluye ReadmeShowcase y futuras capturas para el README
├── APP_GYMTests/
├── APP_GYMUITests/
└── APP_GYM.xcodeproj
```

## Interfaz

- SwiftUI, pestañas y vistas modales
- Modo claro y oscuro
- SF Symbols

## Contribución

1. Fork del repositorio
2. Rama nueva (`git checkout -b feature/nombre`)
3. Commits claros
4. Pull request a `main`

## Contacto

**José Raúl Soriano Cazabal** — [X @tu_twitter](https://x.com/tu_twitter)

Sustituye `tu_twitter` por tu usuario de X si es distinto.
