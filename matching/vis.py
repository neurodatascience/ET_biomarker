import re
import glob
import itertools
import numpy as np
import pandas as pd
import nibabel as nib
import seaborn as sns
from pathlib import PurePath
import matplotlib.pyplot as plt

from os.path import join as opj

from nilearn.input_data import NiftiMasker
from nilearn import image, plotting, surface
from nilearn.datasets import fetch_surf_fsaverage


def heatmap(data, row_labels, col_labels, ax=None,
            cbar_kw={}, cbarlabel="", **kwargs):
    """
    Create a heatmap from a numpy array and two lists of labels.

    Parameters
    ----------
    data
        A 2D numpy array of shape (N, M).
    row_labels
        A list or array of length N with the labels for the rows.
    col_labels
        A list or array of length M with the labels for the columns.
    ax
        A `matplotlib.axes.Axes` instance to which the heatmap is plotted.  If
        not provided, use current axes or create a new one.  Optional.
    cbar_kw
        A dictionary with arguments to `matplotlib.Figure.colorbar`.  Optional.
    cbarlabel
        The label for the colorbar.  Optional.
    **kwargs
        All other arguments are forwarded to `imshow`.
    """
    if not ax:
        ax = plt.gca()

    # Plot the heatmap
    im = ax.imshow(data, **kwargs)

    # Create colorbar
    cbar = ax.figure.colorbar(im, ax=ax, **cbar_kw)
    cbar.ax.set_ylabel(cbarlabel, rotation=-90, va="bottom")

    # We want to show all ticks...
    ax.set_xticks(np.arange(data.shape[1]))
    ax.set_yticks(np.arange(data.shape[0]))
    # ... and label them with the respective list entries.
    ax.set_xticklabels(col_labels)
    ax.set_yticklabels(row_labels)

    # Let the horizontal axes labeling appear on top.
    ax.tick_params(top=True, bottom=False,
                   labeltop=True, labelbottom=False)

    # Rotate the tick labels and set their alignment.
    plt.setp(ax.get_xticklabels(), rotation=-30, ha="right",
             rotation_mode="anchor")

    # Turn spines off and create white grid.
    for edge, spine in ax.spines.items():
        spine.set_visible(False)

    ax.set_xticks(np.arange(data.shape[1]+1)-.5, minor=True)
    ax.set_yticks(np.arange(data.shape[0]+1)-.5, minor=True)
    ax.grid(which="minor", color="w", linestyle='-', linewidth=3)
    ax.tick_params(which="minor", bottom=False, left=False)

    return im, cbar

def annotate_heatmap(im, data=None, valfmt="{x:.2f}",
                     textcolors=["black", "white"],
                     threshold=None, **textkw):
    """
    A function to annotate a heatmap.

    Parameters
    ----------
    im
        The AxesImage to be labeled.
    data
        Data used to annotate.  If None, the image's data is used.  Optional.
    valfmt
        The format of the annotations inside the heatmap.  This should either
        use the string format method, e.g. "$ {x:.2f}", or be a
        `matplotlib.ticker.Formatter`.  Optional.
    textcolors
        A list or array of two color specifications.  The first is used for
        values below a threshold, the second for those above.  Optional.
    threshold
        Value in data units according to which the colors from textcolors are
        applied.  If None (the default) uses the middle of the colormap as
        separation.  Optional.
    **kwargs
        All other arguments are forwarded to each call to `text` used to create
        the text labels.
    """
    import matplotlib
    if not isinstance(data, (list, np.ndarray)):
        data = im.get_array()

    # Normalize the threshold to the images color range.
    if threshold is not None:
        threshold = im.norm(threshold)
    else:
        threshold = im.norm(data.max())/2.

    # Set default alignment to center, but allow it to be
    # overwritten by textkw.
    kw = dict(horizontalalignment="center",
              verticalalignment="center")
    kw.update(textkw)

    # Get the formatter in case a string is supplied
    if isinstance(valfmt, str):
        valfmt = matplotlib.ticker.StrMethodFormatter(valfmt)

    # Loop over the data and create a `Text` for each "pixel".
    # Change the text's color depending on the data.
    texts = []
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            kw.update(color=textcolors[int(abs(im.norm(data[i, j])) > threshold)])
            text = im.axes.text(j, i, valfmt(data[i, j], None), **kw)
            texts.append(text)
    return texts

# test code
#fig, ax = plt.subplots()
#im, cbar = heatmap(harvest, vegetables, farmers, ax=ax, cmap="coolwarm", cbarlabel="p-val")
#texts = annotate_heatmap(im, valfmt="{x:.4f}")
#fig.tight_layout(); plt.show()



### reference codes
def _clean_alignment(row, decomp):
    """
    Cleaning function for a pd.DataFrame to return the number
    of components used in the decomposition.
    Parameters
    ----------
    alignment : pd.Series
        A pd.Series object denoting the used alignment stimuli.
        Must contain the substring provided in `decomp`
    decomp : str
        Must be a str in ['pca', 'srm']
    """
    try:
        decomp_n_comps, stim = row['alignment'].split(sep=' of ')
        n_comps = decomp_n_comps[len(decomp):]
    except ValueError:  # Too many values to unpack
        n_comps, stim = 'Full', row['alignment']

    return {'n_comps': n_comps, 'stim': stim}


def _create_norm_df(data_dir, decomp=None):
    """
    Creates a pandas dataframe where decoding accuracy scores are normalized
    by scores from anatomical-only alignment for the same cross-validation
    fold.
    Parameters
    ----------
    data_dir: str
        File path to the local directory with CSV results from
        `try_methods_decoding`
    decomp : None or str
        Whether to plot ISC for decompositions of the alignment stimuli.
        If provided, must be a string in ['srm', 'pca']
    """
    cols = ['data', 'task', 'roi', 'method',
            'alignment', 'cv_fold', 'scores']
    scores_df = pd.DataFrame(columns=cols)
    method_path = '*.csv'

    scores_csv = sorted(glob.glob(opj(data_dir, method_path)))
    scores_csv = [csv for csv in scores_csv if 'timings' not in csv]

    if decomp is not None:
        # FIXME: It's so ugly...
        if decomp == 'srm':
            to_remove = 'pca'
        elif decomp == 'pca':
            to_remove = 'srm'
        scores_csv = [csv for csv in scores_csv if f'on_{to_remove}' not in csv]
    else:
        scores_csv = [csv for csv in scores_csv if '_of_' not in csv]

    for csv in scores_csv:
        fname = PurePath(csv).stem
        fileparts = fname.split('_')
        data, task, roi = fileparts[0], fileparts[1], fileparts[2]
        method = ' '.join(fileparts[3:6])
        alignment = ' '.join(fileparts[-4:])

        # light cleaning for legibility
        method = method.strip(' on')
        alignment = alignment.split('on ')[-1]

        with open(csv, 'r') as f:
            scores = f.read().rstrip().split(',')
            scores = [float(re.sub('[^A-Za-z0-9.]+', '', s))
                    for s in scores]
        cv = np.arange(len(scores))

        df = pd.DataFrame(
            dict(zip(cols, [data, task, roi, method, alignment, cv, scores])))
        scores_df = pd.concat([scores_df, df],
                            axis=0, ignore_index=True)

    # normalize scores against anat_inter_subject method
    idx_vars = ['data', 'task', 'roi', 'alignment', 'cv_fold']
    pivot = pd.pivot_table(scores_df, values='scores', columns='method',
                           index=idx_vars)
    # get difference score and convert to percent
    normalized = (pivot - np.asarray(pivot[['anat inter subject']])) * 100
    normalized = normalized.reset_index().drop(
        ['anat inter subject'], axis=1)
    norm_scores_df = pd.melt(normalized, id_vars=idx_vars,
                             value_name='normalized_score')

    norm_scores_df['method'] = norm_scores_df['method'].astype('category')

    return norm_scores_df


def draw_learning_curve(data_dir, decomp='srm'):
    """
    Create pseudo "learning curves" across n_comps for the provided
    decomposition method.
    Note that learning curves are only generated for the pairwise scaled
    orthgonal alignment method, and normalized against decoding accuracy
    with anatomical only alignment.
    Parameters
    ----------
    data_dir: str
        File path to the local directory with CSV results from
        `try_methods_decoding`
    decomp : str
        Whether to plot ISC for decompositions of the alignment stimuli.
        Must be a string in ['srm', 'pca']
    """
    if decomp not in ['srm', 'pca']:
        err_msg = ('Unrecognized alignment stimuli decomposition type ! '
                   'Must be srm or pca.')
        raise ValueError(err_msg)

    norm_scores_df = _create_norm_df(data_dir, decomp=decomp)

    # create n_comps column
    align_df = norm_scores_df.apply(
        _clean_alignment, decomp=decomp,
        axis=1, result_type='expand')
    norm_scores_df = pd.concat([norm_scores_df, align_df], axis='columns')
    norm_scores_df['n_comps'] = \
        pd.Categorical(norm_scores_df['n_comps'].astype(str),
                       ['25', '50', '75', '100', '150', '200', 'Full'], ordered=True)

    sns_plt = sns.lineplot(
        x='n_comps', y='normalized_score', hue='stim',
        data=norm_scores_df.query('method == "pairwise scaled orthogonal"'),
        sort=True, ci='sd', palette='husl'
    )
    fig = sns_plt.get_figure()
    # ax.axhline(0, c='black', linestyle='dashed')
    # ax.set_ylabel('Change in percent accuracy from anatomical alignment')
    fig.savefig(f'cneuro_wm_learning_curve_with_{decomp}.png',
                dpi=300, bbox_inches='tight')
    plt.close(fig=fig)


def visualize_distributions(data_dir, decomp=None):
    """
    Create boxplots to visualize distributions for cross-validated
    decoding accuracies. Can pass `decomp` to consider alignment stimuli
    decomposed with the provided decomp method, in which case all generated
    n_comp values are returned.
    Parameters
    ----------
    data_dir: str
        File path to the local directory with CSV results from
        `try_methods_decoding`
    decomp : None or str
        Whether to plot ISC for decompositions of the alignment stimuli.
        If provided, must be a string in ['srm', 'pca']
    """
    norm_scores_df = _create_norm_df(data_dir)

    ax = sns.catplot(
        x='normalized_score', y='alignment', hue='method',
        data=norm_scores_df,
        kind='box',
        order=sorted(list(norm_scores_df['alignment'].unique())),
        palette="rocket",
        sharex=False
    )

    # FIXME : Hard-coding by task.
    if decomp is None:
        fig_title = 'cneuro_wm_decoding.png'
    else:
        fig_title = f'cneuro_wm_decoding_on_{decomp}_stimuli.png'

    for a in ax.axes.flat:
        a.axvline(0, c='black', linestyle='dashed')
    ax.set_xlabels('Change in percent accuracy from anatomical alignment')
    ax.savefig(fig_title, dpi=300, bbox_inches='tight')
    plt.close(fig=ax.fig)


def plot_surf_im(kind, data_dir, fsaverage=fetch_surf_fsaverage(),
                 colorbar=False, threshold=0.1, vmax=0.75,
                 hemi="left", view="lateral"):
    """
    kind : str
        Kind of ISC, must be in ['spatial', 'temporal']
    data_dir : str
        The path to the postprocess data directory on disk.
        Should contain all generated ISC maps.
    """
    tasks = ['bourne', 'figures_run-1', 'figures_run-2',
             'life_run-1', 'life_run-2', 'wolf']
    methods = ['anat_inter_subject', 'pairwise_scaled_orthogonal']

    if kind not in ['spatial', 'temporal']:
        err_msg = 'Unrecognized ISC type! Must be spatial or temporal'
        raise ValueError(err_msg)

    for task, method in itertools.product(tasks, methods):
        isc_files = sorted(glob.glob(opj(
            data_dir, f'{kind}ISC*{method}*{task}.nii.gz')))
        average_isc = image.mean_img(isc_files)

        texture = surface.vol_to_surf(average_isc, fsaverage.pial_left)
        plotting.plot_surf_stat_map(
            fsaverage.pial_left, texture, hemi=hemi,
            colorbar=colorbar, threshold=threshold, vmax=vmax,
            bg_map=fsaverage.sulc_left, view=view)
        plt.savefig(f'surfplot_{kind}ISC_with_{method}_on_{task}.png',
                    bbox_inches='tight')


def plot_corr_mtx(kind, data_dir, mask_img):
    """
    kind : str
        Kind of ISC, must be in ['spatial', 'temporal']
    data_dir : str
        The path to the postprocess data directory on disk.
        Should contain all generated ISC maps.
    mask_img : str
        Path to the mask image on disk.
    """
    from netneurotools.plotting import plot_mod_heatmap
    methods = ['anat_inter_subject', 'pairwise_scaled_orthogonal']
    if kind not in ['spatial', 'temporal']:
        err_msg = 'Unrecognized ISC type! Must be spatial or temporal'
        raise ValueError(err_msg)

    for method in methods:
        isc_files = sorted(glob.glob(opj(
            data_dir, f'{kind}ISC*{method}*.nii.gz')))
        masker = NiftiMasker(mask_img=mask_img)

        isc = [masker.fit_transform(i).mean(axis=0) for i in isc_files]
        corr = np.corrcoef(np.row_stack(isc))

        # our 'communities' are which film was presented
        movies = [i.split('_on_')[-1].strip('.nii.gz') for i in isc_files]
        num = [i for i, m in enumerate(set(movies))]
        mapping = dict(zip(set(movies), num))
        comm = list(map(mapping.get, movies))

        plot_mod_heatmap(corr, communities=np.asarray(comm),
                         inds=range(len(corr)), edgecolor='white')
        plt.savefig(f'{kind}ISC_correlation_matrix_with_{method}.png',
                    bbox_inches='tight')


def plot_axial_slice(kind, data_dir, decomp=None):
    """
    Parameters
    ----------
    kind : str
        Kind of ISC, must be in ['spatial', 'temporal']
    data_dir : str
        The path to the postprocessed data directory on disk.
        Should contain all generated ISC maps.
    decomp : None or str
        Whether to plot ISC for decompositions of the alignment stimuli.
        If provided, must be a string in ['srm', 'pca']
    """
    tasks = ['bourne', 'figures_run-1', 'figures_run-2',
             'life_run-1', 'life_run-2', 'wolf']

    if decomp is not None:
        n_comps = [25, 50, 75, 100, 150, 200]
        tasks = [f'{decomp}{n}_of_{t}' for t in tasks for n in n_comps]

    methods = ['anat_inter_subject', 'pairwise_scaled_orthogonal', 'smoothing']
    if kind not in ['spatial', 'temporal']:
        err_msg = 'Unrecognized ISC type! Must be spatial or temporal'
        raise ValueError(err_msg)

    for task, method in itertools.product(tasks, methods):
        files = glob.glob(opj(
            data_dir, f'{kind}ISC_*{method}*_on_{task}.nii.gz'))
        files = [f for f in files if 'source' not in f]
        average = image.mean_img(files)

        # NOTE: threshold may need to be adjusted for each decoding task
        plotting.plot_stat_map(
            average,
            threshold=0.1, vmax=0.75, symmetric_cbar=False,
            display_mode='z', cut_coords=[-24, -6, 7, 25, 37, 51, 65]
        )
        plt.savefig(f'{kind}ISC_with_{method}_on_{task}.png',
                    bbox_inches='tight')


def plot_hcp24_axial_slice(data_dir, subjectwise=False):
    """
    Parameters
    ----------
    data_dir : str
        The path to the postprocessed data directory on disk.
        Should contain all generated ISC maps for the HCP24
        contrast maps.
    subjectwise : bool
        Whether to return ISC maps by individual target subjects or
        averaging across all target subjects. Defaults to False; i.e.
        averaging across all target subjects.
    """
    tasks = ['bourne', 'figures_run-1', 'figures_run-2',
             'life_run-1', 'life_run-2', 'wolf']
    methods = ['anat_inter_subject', 'pairwise_scaled_orthogonal', 'smoothing']
    task_labels = ['emotion', 'gambling', 'language', 'motor',
                   'relational', 'social', 'working_memory']
    task_slicing = [slice(0,2), slice(2,4), slice(4,6), slice(6,12),
                    slice(12,14), slice(14,16), slice(16,24)]

    for task, method in itertools.product(tasks, methods):
        files = glob.glob(opj(
            data_dir, f'spatialISC_*{method}*_on_{task}.nii.gz'))
        files = [f for f in files if 'source' in f]
        ref_file = files[0]  # assume consistent affine

        if subjectwise:
            folds = set([f.split('fold')[1].split('_')[0] for f in files])
            for fold in folds:
                subject_files = [f for f in files if f'fold{fold}' in f]
                data = [nib.load(s).get_fdata() for s in subject_files]
                average = np.mean(data, axis=0)

                fig, axes = plt.subplots(7, 1, figsize=(15,15))

                for slc, label, ax in zip(task_slicing, task_labels, axes):
                    task_isc = image.new_img_like(ref_file, average[..., slc])
                    plotting.plot_stat_map(
                        image.mean_img(task_isc), threshold=0.05,
                        vmax=0.75, symmetric_cbar=False, display_mode='z',
                        title=label, axes=ax,
                        cut_coords=[-24, -6, 7, 25, 37, 51, 65])
                plt.savefig(
                    f'spatialISC_with_{method}_on_fold{fold}_{task}.png',
                    bbox_inches='tight')

        else:
            data = [nib.load(f).get_fdata() for f in files]
            average = np.mean(data, axis=0)

            fig, axes = plt.subplots(7, 1, figsize=(15,15))

            for slc, label, ax in zip(task_slicing, task_labels, axes):
                task_isc = image.new_img_like(ref_file, average[..., slc])
                plotting.plot_stat_map(
                    image.mean_img(task_isc),
                    threshold=0.05, vmax=0.75, symmetric_cbar=False,
                    title=label, axes=ax,
                    display_mode='z', cut_coords=[-24, -6, 7, 25, 37, 51, 65]
                )
            plt.savefig(f'spatialISC_with_{method}_on_{task}.png',
                        bbox_inches='tight')