# ssd-sql-tools
## Standard Safeguarding Dataset SQL toolset

[this is a working/in progress repo]<br>
Providing the needed toolset for creating the SSD within existing infrastructures* and aimed for near-zero overheads for your LA. 
*(local, platform agnostic or with the tools to enable this)

#### Phase 1
- [create the ssd for LiquidLogic](ssd_create_liquid_logic)
- [create the ssd for Mosaic](ssd_create_mosaic)

#### Phase 2
- [create the ssd for Care Director](ssd_create_care_director)
- [create the ssd for Azeus](ssd_create_azeus)
- [create the ssd for Eclipse]
- [create the ssd for Paris]

<br><br>
Because of common constraints/security restrictions within LA's*, the extract development process has two core outputs to enable extract alpha-testing across LA's.
<br>
#### For each SSD object/table extract scripts create:
- [i]  <b>persistent</b> SSD table/object structure (files suffixed ..._per.sql) - e.g ssd_person_per.sql
- [ii] <b>temporary</b> version of SSD table/object structure within the db #temp namespace (files suffixed ..._tmp.sql) - e.g ssd_person_tmp.sql

*<i>We have noted that a majority of LA data team access to raw CMS db tables/schemas is limited. Working in the temp namespace/schema allows us to work around this in the early stages. </i>

<br><br>
Alongside creating the SSD from any CMS system and most common DB's(Initially towards _SQL Server_ & _Oracle_ compatibility), the aim is to provide a collaborative collection of SQL scripts developed specifically to work against the SSD to enable both statutory returns and further data analysis. Feedback and contributions from any local authority data stakeholders are welcomed.  SQL based queries, interogation and analysis can also be pre-emptively developed against the SSD schema as detailed/maintained here: [ssd-data-model on GitHub Pages](https://data-to-insight.github.io/ssd-data-model/index.html) . 
<br><br>
We're pre-emptively developing the required SQL based tools for generating the current DfE stat-returns. 
- [dfe_stat_returns/SSD_AnnexA/](dfe_stat_returns)
- [dfe_stat_returns/SSD_903/](dfe_stat_returns)
- [dfe_stat_returns/SSD_CIN/](dfe_stat_returns)
- [dfe_stat_returns/SSD_RIIA/](dfe_stat_returns)
