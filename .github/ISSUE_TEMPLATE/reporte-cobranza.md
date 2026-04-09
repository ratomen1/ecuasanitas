---
name: Reporte de Cobranza/Emisión
about: Solicitar script de verificación de emisión y cobranza (asignable a Copilot)
title: "[COBRANZA] "
labels: ["sql", "cobranza", "copilot"]
assignees: ''
---

## Período de Emisión
<!-- Ej: 2026-04-01, 2026-04-15 -->
- Fecha emisión: 

## Tipo de Verificación
- [ ] PASO 0: Contratos sin cuota del mes
- [ ] PASO 1: Contratos con malas cuotas (fechainicio > fechapago)
- [ ] PASO 2: Órdenes emitidas con mes ya pagado
- [ ] PASO 5: Duplicados en detalleemision
- [ ] PASO 7: Errores de emisión (débito/recaudación domicilio)
- [ ] PASO 8: Contratos ACT/SUS sin orden emitida
- [ ] PASO 10: Contratos con fechapago posterior a emisión
- [ ] PASO 11: Órdenes con error de cobranza
- [ ] Validación Genesys vs Luca
- [ ] Otro: ___

## Filtros Adicionales
<!-- convenio_id, tiporecaudacion, servicio_id, etc. -->

## Contexto
<!-- Información adicional relevante -->

