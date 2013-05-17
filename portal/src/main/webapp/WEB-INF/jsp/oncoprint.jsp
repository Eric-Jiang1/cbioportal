<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<div id="oncoprint" style="padding-top:10px; padding-bottom:10px; padding-left:10px; border: 1px solid #CCC;">
    <img id="loader_img" src="images/ajax-loader.gif"/>
    <div style="display:none;" id="everything">
        <h4>OncoPrint
            <small>(<a href="faq.jsp#what-are-oncoprints">What are OncoPrints?</a>)</small>
        </h4>

        <form id="oncoprintForm" action="oncoprint_converter.svg" enctype="multipart/form-data" method="POST"
              onsubmit="this.elements['xml'].value=oncoprint.getOncoPrintBodyXML(); return true;" target="_blank">
            <input type="hidden" name="xml">
            <input type="hidden" name="longest_label_length">
            <input type="hidden" name="format" value="svg">
            <p>Download OncoPrint:&nbsp;&nbsp;&nbsp;<input type="submit" value="SVG"></p>
        </form>

        <div id="oncoprint_controls">
            <style>
                .onco-customize {
                    color:#2153AA; font-weight: bold; cursor: pointer;
                }
                .onco-customize:hover { text-decoration: underline; }
            </style>
            <p onclick="$('#oncoprint_controls table').toggle(); $('#oncoprint_controls .triangle').toggle();"
               style="display:none; margin-bottom: 0px;">
                <span class='triangle ui-icon ui-icon-triangle-1-e' style='float:left;'></span>
                <span class='triangle ui-icon ui-icon-triangle-1-s' style='float:left; display:none;'></span>
                <span class='onco-customize'>Customize</span>
            </p>
            <table style="padding-left:13px; padding-top:5px; display:none;">
                <tr>
                    <td><input type='checkbox' onclick='oncoprint.toggleUnaltered();'>Remove Unaltered Cases</td>
                    <td><input type='checkbox' onclick='if ($(this).is(":checked")) {oncoprint.defaultSort();} else {oncoprint.memoSort();}'>Restore Case Order<img src="images/help.png" title="sort cases alphabetically by case ID, or as defined in the original query" onload="$(this).tipTip();" ></td>
                </tr>

                <tr>
                    <td style="padding-right: 15px;"><span>Zoom</span><div id="zoom" style="display: inline-table;"></div></td>
                    <td><input type='checkbox' onclick='oncoprint.toggleWhiteSpace();'>Remove Whitespace</td>
                </tr>
            </table>
        </div>
        <div id="oncoprint_body">
            <script type="text/javascript" src="js/oncoprint.js"></script>

            <script type="text/javascript">
                var oncoPrintParams = {
                    geneData: undefined,
                    cancer_study_id: "<%=cancerTypeId%>",
                    case_set_str: "<%=StringEscapeUtils.escapeHtml(OncoPrintUtil.getCaseSetDescription(caseSetId, caseSets))%>",
                    num_cases_affected: "<%=dataSummary.getNumCasesAffected()%>",
                    percent_cases_affected: "<%=OncoPrintUtil.alterationValueToString(dataSummary.getPercentCasesAffected())%>",
                    vis_key: true,
                    customize: true
                };

                // hack to get the proper case set parameter
                // for a particular query
                //
                // takes an object literal and injects the proper case set parameter for an ajax request,
                // and returns the now *modified* object
                var injectCaseSet = (function() {
                    var case_set_id = "<%=caseSetId%>";
                    var cases = "<%=caseIds%>";
                    var case_ids_key = "<%=caseIdsKey%>";

                    var key, value;

                    if (cases !== "") {
                        key = "cases";
                        value = cases;
                    }
                    else if (case_ids_key !== "") {
                        key = "case_ids_key";
                        value = case_ids_key;
                    }
                    else if (case_set_id !== "") {
                        key = "case_set_id";
                        value = case_set_id;
                    }

                    return function(obj) {
                        obj[key] = value;
                        return obj;
                    };
                })();

                var geneDataQuery = {
                    cancer_study_id: "<%=cancerTypeId%>",
                    genes: genes,
                    geneticProfileIds: geneticProfiles,
                    z_score_threshold: <%=zScoreThreshold%>,
                    rppa_score_threshold: <%=rppaScoreThreshold%>
                };
                geneDataQuery = injectCaseSet(geneDataQuery);

                var oncoprint;      // global
                $.post(DataManagerFactory.getGeneDataJsonUrl(), geneDataQuery, function(geneData) {

                    oncoPrintParams['geneData'] = geneData;

                    var clinicals = new ClinicalColl([], {
                        case_set_id: "<%=caseSetId%>"
                    });
                    clinicals.fetch({
                        "success": function(clinicalData) {
                            oncoPrintParams['clinicalData'] = clinicalData.toJSON();

                            oncoPrintParams['genes'] = genes.split(" ");
                            oncoPrintParams['clinical_attrs'] = ["VITAL_STATUS", "DAYS_TO_DEATH"];

                            oncoprint = Oncoprint($('#oncoprint_body')[0], oncoPrintParams);
                            $('#oncoprint #loader_img').hide();
                            $('#oncoprint #everything').show();

                        }
                    });
                });
            </script>
        </div>

        <div id="oncoprint_legend"></div>
    </div>
</div>
