import pandas as pd
import os
import sys
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

def format_ols_results(res):
    ''' Converts statsmodels summary results (table2) into dataframe with minimum usuful stat results'''

    results_summary = res.summary()
    results_as_html = results_summary.tables[1].as_html()
    res_df = pd.read_html(results_as_html, header=0, index_col=0)[0].reset_index()
    res_df['R2'] = res.rsquared
    res_df['R2_adj'] = res.rsquared_adj

    return res_df