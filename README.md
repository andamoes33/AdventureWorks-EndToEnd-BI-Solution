# 🚲 AdventureWorks: End-to-End Business Intelligence Solution
Análisis Comercial y Financiero para la toma de decisiones ejecutivas mediante la integración de SQL Server y Power BI.

---

## 📌 Presentación del Proyecto
Diseñé e implementé una solución analítica integral (End-to-End) para la dirección Comercial y Financiera de Adventure Works.

Partiendo de la base de datos transaccional (OLTP) AdventureWorks2025 en SQL Server, desarrollé consultas de exploración, procesos de limpieza, validación de calidad de datos y creación de vistas reutilizables. Posteriormente, modelé los datos en Power BI, implementé métricas DAX y un Dashboard Ejecutivo orientado al storytelling interactivo y la toma de decisiones estratégicas.

---

## 🎯 Comprensión del Negocio

### 🏢 Contexto
Adventure Works es una empresa manufacturera y distribuidora de bicicletas, accesorios y ropa deportiva con presencia en diferentes territorios y canales de venta. Las direcciones Comercial y Financiera requerían un tablero de control centralizado para monitorear el desempeño del negocio mediante indicadores clave (KPIs) relacionados con ventas, clientes, vendedores, productos y rentabilidad.

### 🎯 Objetivo del Proyecto
Diseñar e implementar una solución de inteligencia de negocios centralizada que responda a las preguntas clave para las áreas Comercial y Financiera mediante la interacción entre SQL Server y Power BI.

### 📐 Alcance
* 🛒 **Áreas cubiertas:** Ventas netas, desempeño de clientes (Store vs. Retail) y vendedores, catálogo de productos, rendimiento de territorios y rentabilidad financiera.
* 🛠️ **Tecnologías utilizadas:**
  * 🛢️ **SQL Server:** Exploración de datos, transformaciones, validaciones de calidad y vistas (VIEWS).
  * 📊 **Power BI:** Modelado estrella, lenguaje DAX (Time Intelligence y métricas dinámicas) y diseño UX/UI interactivo.
* 🚫 **Exclusiones:** No se incluyeron procesos de manufactura (Supply Chain) ni Recursos Humanos internos.

---

## 🛢️ Comprensión e Integración de Datos
* 🗄️ **Base de datos utilizada:** AdventureWorks2025 es una base de datos transaccional (OLTP)
* ⚙️ **Tipo de base de datos:** Base de datos transaccional desarrollada por Microsoft para simular la operación de una empresa manufacturera (fabricante y distribuidora de bicicletas y accesorios deportivos).
* 🗂 **Esquemas y Tablas Utilizadas:**

| Esquema | Descripción de uso | Tablas Principales |
| :--- | :--- | :--- |
| **Sales** 🛒 | Transacciones de venta, clientes, vendedores y territorios. | SalesOrderHeader, SalesOrderDetail, Customer, Store, SalesTerritory, SalesPerson |
| **Production** 🚲 | Catálogo de productos, categorías, subcategorías y costos. | Product, ProductCategory, ProductSubcategory, ProductCostHistory |
| **Person** 👤 | Entidades de contacto, datos de clientes y regiones geográficas. | Person, CountryRegion |
| **HumanResources** 👥 | Información jerárquica y de empleados vinculados a ventas. | Employee |

---

## 🏗️ Arquitectura y Modelo Conceptual

El flujo transaccional se integró asegurando la trazabilidad completa desde la generación del pedido hasta la consolidación territorial y financiera.

```text
                                            [ Person ] ──(BusinessEntityID)──> [ SalesPerson ] ──(BusinessEntityID)──> [ Employee ]
                                                                                      │
                                                                        (SalesPersonID / BusinessEntityID)
                                                                                      │
                                                                                      ▼
[ Person ] ──(PersonID / BusinessEntityID)──> [ Customer ] ──(CustomerID)──> [ SalesOrderHeader ] <──(TerritoryID)── [ SalesTerritory ] ──(CountryRegionCode)──> [ CountryRegion ]
                                                   │                                  │
                                          (StoreID / BusinessEntityID)           (SalesOrderID)
                                                   │                                  │
                                                   ▼                                  ▼
                                                [ Store ]                   [ SalesOrderDetail ]
                                                                                      │
                                                                                 (ProductID)
                                                                                      │
                                                                                      ▼
                                                                          [ ProductCostHistory ]
                                                                                      │
                                                                                 (ProductID)
                                                                                      │
                                                                                      ▼
                                                                                 [ Product ]
                                                                                      │
                                                                           (ProductSubcategoryID)
                                                                                      │
                                                                                      ▼
                                                                          [ ProductSubcategory ]
                                                                                      │
                                                                            (ProductCategoryID)
                                                                                      │
                                                                                      ▼
                                                                              [ ProductCategory ]
```

> 💡 **Caso Especial de Integración:** En la vista de vendedores (`SalesPerson`), se unieron `Person`, `SalesPerson` y `Employee`. Adicionalmente, mediante SQL se incorporó el registro explícito con `BusinessEntityID = -1` (*'Online Sales'*), garantizando que las ventas digitales no perdieran integridad ni representación en el modelo de datos.

---

## 🔄 Flujo del Proceso de Negocio
Para modelar correctamente la base de datos, se analizó el ciclo de vida completo de una transacción comercial:

1. **Cliente 👤:** Realiza una compra directamente mediante el canal digital o a través de un ejecutivo de ventas (*Salesperson*).
2. **Encabezado del Pedido 📄:** Se genera un registro principal en `SalesOrderHeader` con los datos generales de la transacción. En caso de que sea una venta por el canal digital, se asocia en la columna *OnlineOrderFlag*.
3. **Detalle del Pedido 📦:** Se agregan los productos específicos adquiridos en `SalesOrderDetail`.
4. **Categorización 🏷️:** Cada producto se vincula a su respectiva subcategoría y categoría en el catálogo.
5. **Asignación Territorial 🌍:** Sin importar el canal de venta (físico o digital), la transacción queda asociada a una zona geográfica determinada.
6. **Consolidación Financiera 💰:** Se calcula e ingresa el importe total, aplicando impuestos, fletes y descuentos.

---
## 💡 Preguntas de Negocio Resueltas

### 📊 Área Comercial
* 💻 **Análisis de Canales de Venta:** ¿Cuál es el porcentaje de participación de las ventas Online en comparación con el total de ventas?
* 🎟️ **Valor Promedio por Transacción:** ¿Cuál es el Ticket Promedio o ATV (*Average Transaction Value*) del negocio?
* 📈 **Volumen y Base de Clientes:** ¿Cuántos clientes de tipo tienda (*Store*) y clientes finales (*Online*) se encuentran activos en el período?
* 📅 **Evolución Temporal:** ¿Cuál es la evolución y tasa de crecimiento de las ventas en comparativas mensuales y anuales?
* 🌍 **Desempeño Territorial:** ¿Qué territorios generan mayores ventas y cuál es la contribución de cada territorio al total de ventas?
* 📦 **Análisis por Categoría:** ¿Qué categorías generan mayor volumen de ingresos y cuál es su participación porcentual sobre el total de ventas?
* 🏆 **Top de Productos:** ¿Cuáles son los Top 10 productos con mayor volumen de ventas netas?
* 👔 **Desempeño de Vendedores:** ¿Cómo se desempeñan los ejecutivos de venta según su zona geográfica asignada? (Visualizado mediante Tooltips dinámicos).
* 👥 **Identificación de Clientes Clave:** ¿Quiénes son los clientes que generan mayores ventas acumuladas?

### 💰 Área Financiera & Rentabilidad
* 🏷️ **Impacto de Descuentos:** ¿Qué porcentaje representan los descuentos aplicados sobre el total de las ventas brutas?
* 📊 **Rentabilidad Consolidada:** ¿Cuál es la utilidad bruta global y el porcentaje de margen de ganancia por período?
* 🛡️ **Cobertura de Costos:** ¿Cuál es el porcentaje de cubrimiento del costo estándar histórico frente al total de ventas netas?
* 📈 **Tendencia de Rentabilidad:** ¿Cómo evolucionan las ventas y el margen bruto a lo largo del tiempo utilizando el costo estándar histórico real?
* 🔄 **Comparativa Anual (Prior Year):** ¿Cuál es la utilidad bruta actual y su comportamiento respecto al año anterior (*Prior Year*) por categoría?
* 🏷️ **Margen Real por Producto:** ¿Cuál es la utilidad y el porcentaje de margen bruto por producto, calculados a partir del costo histórico real a la fecha de transacción (`StandardCostHistory`)-------------?
* 👑 **Top Clientes por Rentabilidad:** ¿Quiénes son los clientes más rentables en términos de utilidad bruta?, ¿cuál es su porcentaje de margen y cómo evoluciona su margen interanual (*YoY*)?

---

## 🛠️ Estrategia de Desarrollo (Step-by-Step)

1. 🛢️ **Conexión a Base de Datos:** Establecimiento del entorno de trabajo sobre la base transaccional (OLTP) AdventureWorks2025 en SQL Server.
2. 🔍 **Exploración de Datos:** Análisis inicial de esquemas, estructuras, llaves primarias/foráneas y cardinalidades en SQL.
3. 🧹 **Limpieza y Consultas SQL:** Desarrollo de scripts para filtrar registros incoherentes, validar nulos y preparar las transformaciones necesarias.
4. 👁️ **Creación de Vistas:** Construcción de vistas optimizadas (`view_dimCustomer`, `view_dim_product`, `view_dim_Sales_Person`, `view_dim_Territory`, `view_fact_sales`) para desacoplar la lógica de la base de datos y facilitar la carga.
5. 🔗 **Integración con Power BI:** Importación y conexión de las vistas SQL desde Power BI Desktop.
6. 🏗️ **Modelo de Datos:** Diseño de un modelo en estrella (*Star Schema*) con relaciones 1 a * y tablas de dimensión/hechos claramente definidas.
7. 📐 **Medidas DAX y KPIs:** Creación de indicadores clave, métricas de Time Intelligence, márgenes dinámicos y análisis de penetración.
8. 📊 **Dashboard Ejecutivo (Storytelling):** Diseño de la interfaz visual orientada a la experiencia de usuario (UX/UI), con navegación fluida, filtros dinámicos y tooltips detallados.
9. 💡 **Hallazgos de Negocio y Recomendaciones:** Identificación de patrones de rentabilidad, alertas de calidad de datos e insights estratégicos para apoyar la toma de decisiones comerciales y financieras.

---

## 📬 Contacto y Redes

* 👨‍💻 **Autor:** Angie Daniela Morales Espinal
* 💼 **LinkedIn:** www.linkedin.com/in/angie-daniela-morales-espinal
* 🌐 **Portafolio:** [Enlace a tu portafolio en Notion/NovyPro]
