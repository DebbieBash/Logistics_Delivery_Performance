<svg width="680" height="740" viewBox="0 0 680 740" xmlns="http://www.w3.org/2000/svg" role="img">
<title>HaulPoint dbt architecture diagram</title>
<desc>Source to staging to intermediate to marts pipeline for Cartwright Freightways delivery performance analytics</desc>
<defs>
  <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M2 1L8 5L2 9" fill="none" stroke="#888780" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </marker>
  <style>
    text { font-family: sans-serif; fill: #2C2C2A; }
    .th { font-size: 13px; font-weight: 500; fill: #2C2C2A; }
    .ts { font-size: 11px; font-weight: 400; fill: #5F5E5A; }
    .arr { stroke: #888780; stroke-width: 1.2; fill: none; }
    .gray-box { fill: #F1EFE8; stroke: #888780; }
    .teal-box { fill: #E1F5EE; stroke: #0F6E56; }
    .purple-box { fill: #EEEDFE; stroke: #534AB7; }
    .coral-box { fill: #FAECE7; stroke: #993C1D; }
    .blue-box { fill: #E6F1FB; stroke: #185FA5; }
    .gray-text { fill: #444441; }
    .teal-text { fill: #085041; }
    .purple-text { fill: #3C3489; }
    .coral-text { fill: #712B13; }
    .blue-text { fill: #0C447C; }
    .divider { stroke: #D3D1C7; stroke-width: 0.5; stroke-dasharray: 4 4; }
  </style>
</defs>

<!-- Background -->
<rect width="680" height="740" fill="#ffffff"/>

<!-- Layer labels -->
<text class="ts" x="30" y="78" text-anchor="middle" dominant-baseline="central">Source</text>
<text class="ts" x="30" y="198" text-anchor="middle" dominant-baseline="central">Staging</text>
<text class="ts" x="30" y="338" text-anchor="middle" dominant-baseline="central">Intermediate</text>
<text class="ts" x="30" y="488" text-anchor="middle" dominant-baseline="central">Marts</text>
<text class="ts" x="30" y="648" text-anchor="middle" dominant-baseline="central">Analysis</text>

<!-- Horizontal dividers -->
<line x1="60" y1="120" x2="660" y2="120" class="divider"/>
<line x1="60" y1="250" x2="660" y2="250" class="divider"/>
<line x1="60" y1="410" x2="660" y2="410" class="divider"/>
<line x1="60" y1="570" x2="660" y2="570" class="divider"/>

<!-- SOURCE LAYER -->
<rect x="70" y="52" width="120" height="44" rx="4" class="gray-box" stroke-width="0.5"/>
<text class="th gray-text" x="130" y="74" text-anchor="middle" dominant-baseline="central">RAW_ORDERS</text>

<rect x="210" y="52" width="140" height="44" rx="4" class="gray-box" stroke-width="0.5"/>
<text class="th gray-text" x="280" y="74" text-anchor="middle" dominant-baseline="central">RAW_DELIVERIES</text>

<rect x="370" y="52" width="140" height="44" rx="4" class="gray-box" stroke-width="0.5"/>
<text class="th gray-text" x="440" y="74" text-anchor="middle" dominant-baseline="central">RAW_WAREHOUSES</text>

<rect x="530" y="52" width="120" height="44" rx="4" class="gray-box" stroke-width="0.5"/>
<text class="th gray-text" x="590" y="74" text-anchor="middle" dominant-baseline="central">RAW_DRIVERS</text>

<!-- SOURCE to STAGING arrows -->
<line x1="130" y1="96" x2="130" y2="152" class="arr" marker-end="url(#arrow)"/>
<line x1="280" y1="96" x2="280" y2="152" class="arr" marker-end="url(#arrow)"/>
<line x1="440" y1="96" x2="440" y2="152" class="arr" marker-end="url(#arrow)"/>
<line x1="590" y1="96" x2="590" y2="152" class="arr" marker-end="url(#arrow)"/>

<!-- STAGING LAYER -->
<rect x="70" y="152" width="120" height="44" rx="4" class="teal-box" stroke-width="0.5"/>
<text class="th teal-text" x="130" y="174" text-anchor="middle" dominant-baseline="central">stg_orders</text>

<rect x="210" y="152" width="140" height="44" rx="4" class="teal-box" stroke-width="0.5"/>
<text class="th teal-text" x="280" y="174" text-anchor="middle" dominant-baseline="central">stg_deliveries</text>

<rect x="370" y="152" width="140" height="44" rx="4" class="teal-box" stroke-width="0.5"/>
<text class="th teal-text" x="440" y="174" text-anchor="middle" dominant-baseline="central">stg_warehouses</text>

<rect x="530" y="152" width="120" height="44" rx="4" class="teal-box" stroke-width="0.5"/>
<text class="th teal-text" x="590" y="174" text-anchor="middle" dominant-baseline="central">stg_drivers</text>

<!-- STAGING to INTERMEDIATE arrows -->
<line x1="130" y1="196" x2="130" y2="272" class="arr" marker-end="url(#arrow)"/>
<line x1="280" y1="196" x2="280" y2="272" class="arr" marker-end="url(#arrow)"/>
<line x1="440" y1="196" x2="440" y2="432" class="arr" marker-end="url(#arrow)"/>
<line x1="590" y1="196" x2="590" y2="432" class="arr" marker-end="url(#arrow)"/>

<!-- INTERMEDIATE LAYER -->
<rect x="70" y="272" width="120" height="44" rx="4" class="purple-box" stroke-width="0.5"/>
<text class="th purple-text" x="130" y="294" text-anchor="middle" dominant-baseline="central">int_orders</text>

<rect x="210" y="272" width="140" height="44" rx="4" class="purple-box" stroke-width="0.5"/>
<text class="th purple-text" x="280" y="294" text-anchor="middle" dominant-baseline="central">int_deliveries</text>

<!-- int_orders + int_deliveries to int_order_delivery -->
<line x1="130" y1="316" x2="205" y2="356" class="arr" marker-end="url(#arrow)"/>
<line x1="280" y1="316" x2="280" y2="356" class="arr" marker-end="url(#arrow)"/>

<rect x="175" y="356" width="210" height="44" rx="4" class="purple-box" stroke-width="0.5"/>
<text class="th purple-text" x="280" y="378" text-anchor="middle" dominant-baseline="central">int_order_delivery</text>

<!-- INTERMEDIATE to MARTS arrows -->
<line x1="230" y1="400" x2="160" y2="432" class="arr" marker-end="url(#arrow)"/>
<line x1="280" y1="400" x2="280" y2="432" class="arr" marker-end="url(#arrow)"/>

<!-- MARTS LAYER -->
<rect x="70" y="432" width="120" height="44" rx="4" class="coral-box" stroke-width="0.5"/>
<text class="th coral-text" x="130" y="454" text-anchor="middle" dominant-baseline="central">fct_orders</text>

<rect x="210" y="432" width="140" height="44" rx="4" class="coral-box" stroke-width="0.5"/>
<text class="th coral-text" x="280" y="454" text-anchor="middle" dominant-baseline="central">fct_deliveries</text>

<rect x="370" y="432" width="140" height="44" rx="4" class="coral-box" stroke-width="0.5"/>
<text class="th coral-text" x="440" y="454" text-anchor="middle" dominant-baseline="central">dim_warehouses</text>

<rect x="530" y="432" width="120" height="44" rx="4" class="coral-box" stroke-width="0.5"/>
<text class="th coral-text" x="590" y="454" text-anchor="middle" dominant-baseline="central">dim_drivers</text>

<!-- MARTS to fct_sla_tracking -->
<line x1="130" y1="476" x2="220" y2="592" class="arr" marker-end="url(#arrow)"/>
<line x1="280" y1="476" x2="280" y2="592" class="arr" marker-end="url(#arrow)"/>

<!-- ANALYSIS LAYER -->
<rect x="150" y="592" width="260" height="44" rx="4" class="blue-box" stroke-width="0.5"/>
<text class="th blue-text" x="280" y="614" text-anchor="middle" dominant-baseline="central">fct_sla_tracking</text>

<line x1="280" y1="636" x2="280" y2="672" class="arr" marker-end="url(#arrow)"/>

<rect x="150" y="672" width="260" height="44" rx="4" class="blue-box" stroke-width="0.5"/>
<text class="th blue-text" x="280" y="694" text-anchor="middle" dominant-baseline="central">reconciliation_bridge</text>

<!-- Legend -->
<rect x="390" y="600" width="14" height="14" rx="2" class="gray-box" stroke-width="0.5"/>
<text class="ts" x="410" y="611">Source (raw)</text>

<rect x="390" y="622" width="14" height="14" rx="2" class="teal-box" stroke-width="0.5"/>
<text class="ts" x="410" y="633">Staging (views)</text>

<rect x="390" y="644" width="14" height="14" rx="2" class="purple-box" stroke-width="0.5"/>
<text class="ts" x="410" y="655">Intermediate (ephemeral)</text>

<rect x="390" y="666" width="14" height="14" rx="2" class="coral-box" stroke-width="0.5"/>
<text class="ts" x="410" y="677">Marts (tables)</text>

<rect x="390" y="688" width="14" height="14" rx="2" class="blue-box" stroke-width="0.5"/>
<text class="ts" x="410" y="699">Analysis (tables)</text>
</svg>
