import numpy as np
import matplotlib.pyplot as plt
from mne.io import read_raw_eyelink
import os

subj_ID = "V001" #input subject ID
asc_path = os.path.join("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Followup/", subj_ID,f"{subj_ID}.asc") #change to your path
raw = read_raw_eyelink(asc_path) #read in the data

x_data, times = raw.get_data(picks='xpos_left', return_times=True) #extract x coordinates and time
y_data, _ = raw.get_data(picks='ypos_left', return_times=True) #exttract y coordinates

x_data = x_data.squeeze()
y_data = y_data.squeeze()

# let's convert data from pixels to degrees of visual angle
def pixels_to_degrees(pixels_x, pixels_y, screen_width_mm, screen_height_mm, screen_resolution_x, screen_resolution_y, viewing_distance_mm):
    """
    pixels_x: NumPy array or scalar of x-coordinates in pixels (from screen center).
    pixels_y: NumPy array or scalar of y-coordinates in pixels (from screen center).
    screen_width_mm: Physical width of the screen in millimeters.
    screen_height_mm: Physical height of the screen in millimeters.
    screen_resolution_x: Screen resolution in pixels (width).
    screen_resolution_y: Screen resolution in pixels (height).
    viewing_distance_mm: Distance from the viewer's eye to the screen in millimeters.


    returns: Tuple of NumPy arrays (degrees_x, degrees_y) in degrees.
    """
    # Calculate physical size of a single pixel in mm
    pixel_size_x = screen_width_mm / screen_resolution_x
    pixel_size_y = screen_height_mm / screen_resolution_y

    # Convert pixel distances from center to physical distances in mm
    distance_mm_x = pixels_x * pixel_size_x
    distance_mm_y = pixels_y * pixel_size_y

    # Calculate the visual angle using the arctangent function (atan)
    # The formula is: angle = atan(opposite / adjacent)
    # opposite = physical distance in mm, adjacent = viewing distance in mm
    degrees_x = np.degrees(np.arctan(distance_mm_x / viewing_distance_mm))
    degrees_y = np.degrees(np.arctan(distance_mm_y / viewing_distance_mm))

    return degrees_x, degrees_y

# Monitor specs example
SCREEN_RES_X = 1920 # resolution width
SCREEN_RES_Y = 1200 # resolution height
PPI = 96 #pixels per inch

# convert screen resolution (pixels) to physical size (mm) from PPI
def screen_px_to_mm(width_px, height_px, ppi):
    mm_per_inch = 25.4

    width_mm = (width_px * mm_per_inch) / ppi
    height_mm = (height_px * mm_per_inch) / ppi

    return width_mm, height_mm

SCREEN_WIDTH_MM, SCREEN_HEIGHT_MM = screen_px_to_mm(SCREEN_RES_X, SCREEN_RES_Y, PPI)

VIEWING_DIST_MM = 540 # 54 cm from center of screen to eye

# Fixation center
CENTER_X = 960
CENTER_Y = 600

x_centered = x_data - CENTER_X
y_centered = y_data - CENTER_Y

# Convert to degrees
gaze_degrees_x, gaze_degrees_y = pixels_to_degrees(
    x_centered, y_centered,
    SCREEN_WIDTH_MM, SCREEN_HEIGHT_MM,
    SCREEN_RES_X, SCREEN_RES_Y,
    VIEWING_DIST_MM
)

# print(f"Gaze X in degrees: {gaze_degrees_x}")
# print(f"Gaze Y in degrees: {gaze_degrees_y}")

# Parameters
sfreq = raw.info['sfreq'] #sampling rate (1000 Hz)
trial_annotations = [ann for ann in raw.annotations if "TRIALID" in ann['description']] #lets grab those events (eg TRIALID 1 etc)
N_trials = len(trial_annotations) #number of trials
degree = 1 #we only want the data that is within 1 degree of center; saw a paper that used 1.5, another used 2.56
vel_threshold = 6 #deg/sec; velocity threshold; some papers use 8
skip_samples = 50
tmin, tmax = -0.5, 7.5  # epoch window in seconds
times_epoch = np.linspace(tmin, tmax, int((tmax - tmin) * sfreq))
n_samples = int(round((tmax - tmin) * sfreq)) #number of samples of entire trial/epoch (8 seconds total)

# preallocate with NaNs
epoch_x = np.full((N_trials, n_samples), np.nan)
epoch_y = np.full((N_trials, n_samples), np.nan)

for i, ann in enumerate(trial_annotations): #let's epoch each trial
    onsets = ann['onset']
    start_sample = int(round((onsets + tmin) * sfreq))
    end_sample = start_sample + n_samples

    if start_sample < 0 or end_sample > len(gaze_degrees_x):
        print(f"Trial {i} is out of bounds: start={start_sample}, end={end_sample}")
        continue

    epoch_x[i,:] = gaze_degrees_x[start_sample:end_sample]
    epoch_y[i,:] = gaze_degrees_y[start_sample:end_sample]

# print(epoch_x.shape)  # (160, n_samples)
# print(epoch_x.shape)  # (160, n_samples)

# debugging plot
idx = 20 #pick a random trial to plot and cheeck her out
plt.figure()
plt.plot(times_epoch, epoch_x[idx, :])
plt.title(f"Trial {idx} - X gaze (deg)")
plt.xlabel("Time (s)")
plt.ylabel("X position (deg)")
plt.show()

plt.figure()
plt.plot(times_epoch, epoch_y[idx, :])
plt.title(f"Trial {idx} - Y gaze (deg)")
plt.xlabel("Time (s)")
plt.ylabel("Y position (deg)")
plt.show()

# # now that the data is epoched, let's separate it by condition but we first gotta import the mat files
# import scipy.io as sio
# trial_filename = os.path.join("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Followup/", subj_ID,"trial_order.mat")
# mat_data = sio.loadmat(trial_filename, chars_as_strings=True, matlab_compatible=True)
# print(mat_data.keys())
# trial_order = mat_data["trial_cell"]
#
# # now we need to convert it into python string
# def matlab_cell_to_str(cell):
#     if isinstance(cell, str):
#         return cell
#     if isinstance(cell, np.ndarray):
#         if cell.size == 1:
#             return str(cell.item())
#         return "".join(map(str, cell.flatten()))
#     return str(cell)
#
# # Extract rows
# env_cond  = np.array([matlab_cell_to_str(trial_order[0, i]).strip() for i in range(trial_order.shape[1])])
# # side_cond = np.array([matlab_cell_to_str(trial_order[1, i]).strip() for i in range(trial_order.shape[1])])
# int_cond  = np.array([matlab_cell_to_str(trial_order[2, i]).strip() for i in range(trial_order.shape[1])])
# anech_uninter   = (env_cond == "anech")  & (int_cond == "uninter")
# anech_inter     = (env_cond == "anech")  & (int_cond == "inter")
# reverb_uninter  = (env_cond == "reverb") & (int_cond == "uninter")
# reverb_inter    = (env_cond == "reverb") & (int_cond == "inter")
#
# epoch_x_anech_uninter  = epoch_x[anech_uninter, :]
# epoch_y_anech_uninter  = epoch_y[anech_uninter, :]
# epoch_x_anech_inter    = epoch_x[anech_inter, :]
# epoch_y_anech_inter    = epoch_y[anech_inter, :]
# epoch_x_reverb_uninter = epoch_x[reverb_uninter, :]
# epoch_y_reverb_uninter = epoch_y[reverb_uninter, :]
# epoch_x_reverb_inter   = epoch_x[reverb_inter, :]
# epoch_y_reverb_inter   = epoch_y[reverb_inter, :]

# now let's do some blink thresholding. IF there were blinks, make it NaN
# AND, if they were fixating, if their fixation was >1 deg, make NaN

# let's start with blinks
blink_mask = np.zeros(len(gaze_degrees_x), dtype=bool)
for ann in raw.annotations:
    desc = ann['description'].lower()
    if 'BAD_blink' in desc:
        blink_start = int(round(ann['onset'] * sfreq))
        blink_end = int(round((ann['onset'] + ann['duration']) * sfreq))
        blink_start = max(0, blink_start)
        blink_end = min(len(blink_mask), blink_end)
        blink_mask[blink_start:blink_end] = True

epoch_blink = np.full((N_trials, n_samples), False, dtype=bool)
for i, ann in enumerate(trial_annotations):
    onset = ann['onset']
    start_sample = int(round((onset + tmin) * sfreq))
    end_sample = start_sample + n_samples

    if start_sample < 0 or end_sample > len(gaze_degrees_x):
        continue

    epoch_blink[i, :] = blink_mask[start_sample:end_sample]

epoch_x_clean = epoch_x.copy()
epoch_y_clean = epoch_y.copy()

epoch_x_clean[epoch_blink] = np.nan
epoch_y_clean[epoch_blink] = np.nan

# alright now let's make NaN if their fixation was >1 deg of center
dist_from_center = np.sqrt(epoch_x_clean**2 + epoch_y_clean**2)
off_fixation = dist_from_center > degree

epoch_x_clean[off_fixation] = np.nan
epoch_y_clean[off_fixation] = np.nan

nan_samples = np.isnan(epoch_x_clean) | np.isnan(epoch_y_clean)
nan_fraction_per_trial = np.mean(nan_samples, axis=1)

bad_trials = nan_fraction_per_trial > 0.5 #bad trial if more than 50% is blink/not fixating
good_trials = ~bad_trials

epoch_x_final = epoch_x_clean[good_trials, :]
epoch_y_final = epoch_y_clean[good_trials, :]


# now that the data is epoched, let's separate it by condition but we first gotta import the mat files that contain the trial order
# in order to separate by condition
import scipy.io as sio
trial_filename = os.path.join("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Followup/", subj_ID,"trial_order.mat")
mat_data = sio.loadmat(trial_filename, chars_as_strings=True, matlab_compatible=True)
print(mat_data.keys())
trial_order = mat_data["trial_cell"]

# now we need to convert it into python string
def matlab_cell_to_str(cell):
    if isinstance(cell, str):
        return cell
    if isinstance(cell, np.ndarray):
        if cell.size == 1:
            return str(cell.item())
        return "".join(map(str, cell.flatten()))
    return str(cell)

# Extract rows
env_cond  = np.array([matlab_cell_to_str(trial_order[0, i]).strip() for i in range(trial_order.shape[1])])
# side_cond = np.array([matlab_cell_to_str(trial_order[1, i]).strip() for i in range(trial_order.shape[1])])
int_cond  = np.array([matlab_cell_to_str(trial_order[2, i]).strip() for i in range(trial_order.shape[1])])
env_cond_good = env_cond[good_trials]
int_cond_good = int_cond[good_trials]


anech_uninter   = (env_cond_good == "anech")  & (int_cond_good == "uninter")
anech_inter     = (env_cond_good == "anech")  & (int_cond_good == "inter")
reverb_uninter  = (env_cond_good == "reverb") & (int_cond_good == "uninter")
reverb_inter    = (env_cond_good == "reverb") & (int_cond_good == "inter")

epoch_x_anech_uninter  = epoch_x_final[anech_uninter, :]
epoch_y_anech_uninter  = epoch_y_final[anech_uninter, :]
epoch_x_anech_inter    = epoch_x_final[anech_inter, :]
epoch_y_anech_inter    = epoch_y_final[anech_inter, :]
epoch_x_reverb_uninter = epoch_x_final[reverb_uninter, :]
epoch_y_reverb_uninter = epoch_y_final[reverb_uninter, :]
epoch_x_reverb_inter   = epoch_x_final[reverb_inter, :]
epoch_y_reverb_inter   = epoch_y_final[reverb_inter, :]

# now let's compute the horizontal, vertical, and scalar velocity from the MATLAB code
def compute_velocity_five_point(x_deg, y_deg, sfreq):
    """
    Parameters
    x_deg : 1D numpy array; horizontal gaze position in degrees.
    y_deg : 1D numpy array; vertical gaze position in degrees.
    sfreq : Sampling frequency in Hz.

    Returns
    vel_x : 1D numpy array; horizontal velocity in deg/s.
    vel_y : 1D numpy array; vertical velocity in deg/s.
    speed : 1D numpy array; scalar velocity in deg/s.
    """
    n = len(x_deg)
    vel_x = np.full(n, np.nan)
    vel_y = np.full(n, np.nan)

    for k in range(2, n - 2):
        x_window = [x_deg[k - 2], x_deg[k - 1], x_deg[k + 1], x_deg[k + 2]]
        y_window = [y_deg[k - 2], y_deg[k - 1], y_deg[k + 1], y_deg[k + 2]]

        if np.any(np.isnan(x_window)) or np.any(np.isnan(y_window)):
            continue

        vel_x[k] = (sfreq / 6.0) * (
            x_deg[k + 2] + x_deg[k + 1] - x_deg[k - 1] - x_deg[k - 2]
        )

        vel_y[k] = (sfreq / 6.0) * (
            y_deg[k + 2] + y_deg[k + 1] - y_deg[k - 1] - y_deg[k - 2]
        )

    speed = np.sqrt(vel_x**2 + vel_y**2)
    return vel_x, vel_y, speed

# we also have to compute the median-based standard deviation estimate (threshold is 6 following maria chait's paper)
def median_based_sd(speed):
    """

    Parameters
    speed: 1D numpy array; scalar velocity.

    Returns
    sigma: median-based SD estimate.
    """
    valid = speed[~np.isnan(speed)]

    if len(valid) == 0:
        return np.nan

    med = np.median(valid)
    sigma = np.sqrt(np.median((valid - med) ** 2))
    return sigma

# now let's detect monocular microsaccades from 1 trial of gaze data in degrees
# this is following the MATLAB code from Haider Raiz Khan 2013 github (get link)
def detect_microsaccades(x_deg,y_deg,sfreq,lam=6,min_duration_ms=5,max_duration_ms=100,min_interval_ms=50,):
    """
    Parameters
    x_deg : 1D numpy array; Horizontal gaze position in degrees for one trial.
    y_deg : 1D numpy array; Vertical gaze position in degrees for one trial.
    sfreq : Sampling frequency in Hz.
    lam :  Velocity threshold multiplier. Default = 6.
    min_duration_ms : Minimum duration in milliseconds. Default = 5 ms.
    max_duration_ms : Maximum duration in milliseconds. Default = 100 ms.
    min_interval_ms : Minimum interval between successive microsaccades in milliseconds.
        starting with default = 50 ms.

    Returns
    events : numpy array, shape (n_events, 4)
        Columns:
        0 = onset sample
        1 = offset sample
        2 = peak velocity (deg/s)
        3 = amplitude (deg)
    speed : 1D numpy array; Scalar velocity time series.
    threshold : Velocity threshold used for this trial.
    """
    vel_x, vel_y, speed = compute_velocity_five_point(x_deg, y_deg, sfreq)

    sigma = median_based_sd(speed)
    threshold = lam * sigma

    min_samples = int(np.ceil((min_duration_ms / 1000.0) * sfreq))
    max_samples = int(np.floor((max_duration_ms / 1000.0) * sfreq))
    min_interval_samples = int(np.ceil((min_interval_ms / 1000.0) * sfreq))

    above = speed >= threshold
    above[np.isnan(above)] = False

    onset_list = []
    offset_list = []
    peak_list = []
    ampl_list = []

    i = 0
    n = len(speed)

    while i < n:
        if above[i]:
            start = i

            while i < n and above[i]:
                i += 1

            end = i - 1
            duration_samples = end - start + 1

            if min_samples <= duration_samples <= max_samples:
                if not np.any(np.isnan(x_deg[start:end + 1])) and not np.any(np.isnan(y_deg[start:end + 1])):
                    peak_velocity = np.nanmax(speed[start:end + 1])

                    amplitude = np.sqrt(
                        (x_deg[end] - x_deg[start]) ** 2 +
                        (y_deg[end] - y_deg[start]) ** 2
                    )

                    onset_list.append(start)
                    offset_list.append(end)
                    peak_list.append(peak_velocity)
                    ampl_list.append(amplitude)
        else:
            i += 1

    # Combine into event array
    if len(onset_list) == 0:
        events = np.empty((0, 4))
        return events, speed, threshold

    events = np.column_stack([
        np.array(onset_list),
        np.array(offset_list),
        np.array(peak_list),
        np.array(ampl_list)
    ])

    # Enforce minimum interval between successive microsaccades
    filtered_events = [events[0]]

    for j in range(1, events.shape[0]):
        prev_offset = filtered_events[-1][1]
        curr_onset = events[j][0]

        if (curr_onset - prev_offset) > min_interval_samples:
            filtered_events.append(events[j])

    events = np.array(filtered_events)

    return events, speed, threshold

# for 1 trial
# trial_idx = 0 #pick a trial
# events, speed, threshold = detect_microsaccades(
#     epoch_x_anech_uninter[trial_idx, :],
#     epoch_y_anech_uninter[trial_idx, :],
#     sfreq,
#     lam=6,
#     min_duration_ms=5,
#     max_duration_ms=100,
#     min_interval_ms=50
# )
#
# print("Threshold:", threshold)
# print("Microsaccades:")
# print(events)
# events contains: [onset_sample, offset_sample, peak_velocity_deg_per_sec, amplitude_deg]
# for ex:
    # events[:, 0]   # onset samples
    # events[:, 1]   # offset samples
    # events[:, 2]   # peak velocities
    # events[:, 3]   # amplitudes

# now let's grad microsaccades for all trials
def detect_microsaccades_all_trials(epoch_x_final, epoch_y_final, sfreq,lam=6, min_duration_ms=5,max_duration_ms=100, min_interval_ms=50):
    """
    Parameters
    epoch_x_final : 2D numpy array; horizontal gaze in degree
    epoch_y_final : 2D numpy array; vertical gaze in degree
    sfreq : Sampling frequency in Hz.

    Returns
    microsaccades_all : List of length n_trials
        Each entry is a numpy array of shape (n_events, 4):
        [onset, offset, peak_velocity, amplitude]
    speed_all :  List of scalar velocity arrays, one per trial
    threshold_all : numpy array; Threshold used for each trial
    """
    n_trials = epoch_x_final.shape[0]

    microsaccades_all = []
    speed_all = []
    threshold_all = np.full(n_trials, np.nan)

    for trial_idx in range(n_trials):
        events, speed, threshold = detect_microsaccades(
            epoch_x_final[trial_idx, :],
            epoch_y_final[trial_idx, :],
            sfreq,
            lam=lam,
            min_duration_ms=min_duration_ms,
            max_duration_ms=max_duration_ms,
            min_interval_ms=min_interval_ms
        )

        microsaccades_all.append(events)
        speed_all.append(speed)
        threshold_all[trial_idx] = threshold

    return microsaccades_all, speed_all, threshold_all

# now let's grab them for each condition
anech_uninter_microsaccades, anech_uninter_speed, anech_uninter_threshold = detect_microsaccades_all_trials(
    epoch_x_anech_uninter,
    epoch_y_anech_uninter,
    sfreq,
    lam=6,
    min_duration_ms=5,
    max_duration_ms=100,
    min_interval_ms=50
)

anech_inter_microsaccades, anech_inter_speed, anech_inter_threshold = detect_microsaccades_all_trials(
    epoch_x_anech_inter,
    epoch_y_anech_inter,
    sfreq,
    lam=6,
    min_duration_ms=5,
    max_duration_ms=100,
    min_interval_ms=50
)

reverb_uninter_microsaccades, reverb_uninter_speed, reverb_uninter_threshold = detect_microsaccades_all_trials(
    epoch_x_reverb_uninter,
    epoch_y_reverb_uninter,
    sfreq,
    lam=6,
    min_duration_ms=5,
    max_duration_ms=100,
    min_interval_ms=50
)

reverb_inter_microsaccades, reverb_inter_speed, reverb_inter_threshold = detect_microsaccades_all_trials(
    epoch_x_reverb_inter,
    epoch_y_reverb_inter,
    sfreq,
    lam=6,
    min_duration_ms=5,
    max_duration_ms=100,
    min_interval_ms=50
)

# let's plot her and just see how she looks
# let's check out a cute raster plot
def plot_microsaccade_raster(microsaccades_all, sfreq, tmin, title=""):
    plt.figure()

    for trial_idx, events in enumerate(microsaccades_all):
        if events.shape[0] == 0:
            continue

        # convert onset samples → seconds
        onset_times = events[:, 0] / sfreq + tmin

        plt.vlines(onset_times, trial_idx, trial_idx + 0.8)
        plt.axvline(x=0, color='k', linestyle='--', label='cue')
        # plt.axvline(x=0.95, color='k', linestyle='--', label='stream') #double check this time later
        plt.axvline(x=1.275, color='k', linestyle='--', label='interrupter')

    plt.xlabel("Time (s)")
    plt.ylabel("Trial")
    plt.title(title)
    plt.ylim(0, len(microsaccades_all))
    plt.show()

plot_microsaccade_raster(
    anech_uninter_microsaccades,
    sfreq,
    tmin,
    title="Anech Uninter - Microsaccade Onsets"
)

plot_microsaccade_raster(
    anech_inter_microsaccades,
    sfreq,
    tmin,
    title="Anech Inter - Microsaccade Onsets"
)

# let's also plot the amplitude vs velocity. since this is only single subject, we dont expect a ton
# since on average, there are 1-2 microsaccades/sec
def plot_main_sequence(microsaccades_all, title=""):
    amplitudes = []
    peak_velocities = []

    for events in microsaccades_all:
        if events.shape[0] == 0:
            continue

        amplitudes.extend(events[:, 3])       # amplitude (deg)
        peak_velocities.extend(events[:, 2])  # peak velocity (deg/s)

    amplitudes = np.array(amplitudes)
    peak_velocities = np.array(peak_velocities)

    plt.figure()
    plt.scatter(amplitudes, peak_velocities, alpha=0.6)

    plt.xlabel("Amplitude (deg)")
    plt.ylabel("Peak Velocity (deg/s)")
    plt.title(title)
    plt.show()

plot_main_sequence(
    anech_uninter_microsaccades,
    title="Anech Uninter"
)

plot_main_sequence(
    anech_inter_microsaccades,
    title="Anech Inter"
)

# next to do is make it a binary time series
# let's write a function that converts the current MS list into a logical array
# it wont be a 40x8000 since only X amount of trials contained microsaccades
def microsaccades_to_binary(microsaccades_all, n_samples):
    """
    Parameters
    microsaccades_all : List of length n_trials.
        Each entry is (n_events, 4) array [onset, offset, peak_vel, amplitude]
    n_samples : Number of time samples per trial

    Returns
    binary : np.ndarray (n_trials, n_samples)
        1 = microsaccade present, 0 = none
    """
    n_trials = len(microsaccades_all)
    binary = np.zeros((n_trials, n_samples), dtype=int)

    for trial_idx, events in enumerate(microsaccades_all):

        if events.shape[0] == 0:
            continue

        for ev in events:
            onset = int(ev[0])
            offset = int(ev[1])

            # safety bounds
            onset = max(0, onset)
            offset = min(n_samples - 1, offset)

            binary[trial_idx, onset:offset + 1] = 1

    return binary

n_samples = epoch_x_anech_uninter.shape[1]

anech_uninter_binary = microsaccades_to_binary(
    anech_uninter_microsaccades,
    n_samples
)

n_samples = epoch_x_anech_inter.shape[1]
anech_inter_binary = microsaccades_to_binary(
    anech_inter_microsaccades,
    n_samples
)

n_samples = epoch_x_reverb_uninter.shape[1]
reverb_uninter_binary = microsaccades_to_binary(
    reverb_uninter_microsaccades,
    n_samples
)

n_samples = epoch_x_reverb_inter.shape[1]
reverb_inter_binary = microsaccades_to_binary(
    reverb_inter_microsaccades,
    n_samples
)

# print(anech_uninter_binary.shape)  # should be (n_trials, n_samples)

# trial_idx = 0 #pick a trial
# plt.plot(anech_uninter_binary[trial_idx, :])
# plt.title("Microsaccade Binary ")
# plt.xlabel("Sample")
# plt.ylabel("0/1")
# plt.show()


# plt.plot(times_epoch, np.mean(anech_uninter_binary, axis=0), label="Anech Uninter")
# plt.plot(times_epoch, np.mean(anech_inter_binary, axis=0), label="Anech Inter")
# plt.legend()
# plt.show()

# now let's follow maria chait's paper
from scipy.signal import lfilter

# this is copying Kaho and Claudia's MATLAB code into python
# create a causal smoothing kernel
def smoothing_kernel(sfreq=1000, conv_width=50):
    """
    Parameters
    sfreq : Sampling frequency in Hz.
    conv_width : Kernel width parameter. maria chait used 50.

    Returns
    conv_window : Normalized causal smoothing kernel.
    window_peak : Index of the kernel peak.
    """
    a = 1 / conv_width
    i = np.arange(1, sfreq + 1)  # MATLAB-style 1:sFreq

    conv_window = (a ** 2) * i * np.exp(-a * i)
    conv_window = conv_window / np.max(conv_window)

    window_peak = np.argmax(conv_window)
    return conv_window, window_peak

# def ms_smoothing(ms_list, time_axis, sfreq=1000, conv_width=50):
#     """
#     Smooth microsaccade rate over time using the MATLAB-style causal kernel
#
#     Parameters --
#     ms_list : Binary microsaccade array, shape (n_trials, n_samples).
#     time_axis :  Time axis for the epoch, shape (n_samples,).
#     sfreq : Sampling frequency in Hz.
#     conv_width : Width parameter for kernel. MATLAB used 50.
#
#     Returns --
#     smoothed_ms_data : Smoothed microsaccade rate over time
#     new_time_axis : Shifted time axis accounting for kernel delay
#     time_point_average : Unsmoothed microsaccade rate over time
#     conv_window : The smoothing kernel
#     """
#     # average across trials at each time point
#     time_point_average = np.nanmean(ms_list, axis=0)
#
#     # generate causal smoothing kernel
#     conv_window, window_peak = smoothing_kernel(sfreq=sfreq, conv_width=conv_width)
#
#     # apply kernel causally
#     smoothed_ms_data = lfilter(conv_window, 1, time_point_average)
#
#     # shift time axis to account for kernel peak
#     shift_window = window_peak / sfreq
#     new_time_axis = time_axis - shift_window
#     new_time_axis = np.ceil(new_time_axis * 1000) / 1000
#
#     return smoothed_ms_data, new_time_axis, time_point_average, conv_window

# anech_uninter_smoothed, anech_uninter_time, anech_uninter_raw_rate, _ = ms_smoothing(
#     anech_uninter_binary, times_epoch, sfreq=int(sfreq), conv_width=50
# )
#
# anech_inter_smoothed, anech_inter_time, anech_inter_raw_rate, _ = ms_smoothing(
#     anech_inter_binary, times_epoch, sfreq=int(sfreq), conv_width=50
# )
#
# reverb_uninter_smoothed, reverb_uninter_time, reverb_uninter_raw_rate, _ = ms_smoothing(
#     reverb_uninter_binary, times_epoch, sfreq=int(sfreq), conv_width=50
# )
#
# reverb_inter_smoothed, reverb_inter_time, reverb_inter_raw_rate, _ = ms_smoothing(
#     reverb_inter_binary, times_epoch, sfreq=int(sfreq), conv_width=50
# )

# plt.figure()
# plt.plot(anech_uninter_time, anech_uninter_raw_rate, label="Raw rate")
# plt.plot(anech_uninter_time, anech_uninter_smoothed, label="Smoothed rate")
# plt.xlabel("Time (s)")
# plt.ylabel("Microsaccade rate")
# plt.title("Anech Uninter Microsaccade Rate")
# plt.legend()
# plt.show()

# plt.figure()
# plt.plot(anech_uninter_time, anech_uninter_smoothed, label="Anech Uninter")
# plt.plot(anech_inter_time, anech_inter_smoothed, label="Anech Inter")
# plt.plot(reverb_uninter_time, reverb_uninter_smoothed, label="Reverb Uninter")
# plt.plot(reverb_inter_time, reverb_inter_smoothed, label="Reverb Inter")
#
# plt.xlabel("Time (s)")
# plt.ylabel("Microsaccade rate")
# plt.title("Microsaccade Rate Over Time")
# plt.legend()
# plt.show()

# let's get the mean and SEM so we can plot it w error bars

from scipy.signal import lfilter

# let's compute the rate of microsaccades following Kaho and Claudia's MATLAB, and also plot it over time
# with the mean and SEM

def smooth_ms_trials(ms_binary, time_axis, sfreq=1000, conv_width=50,):
    """
    Parameters
    ms_binary : Binary microsaccade array
    time_axis : Epoch time vector
    sfreq : Sampling frequency
    conv_width : Width parameter for causal kernel

    Returns
    mean_smoothed : array, shape (n_samples,)
    sem_smoothed : array, shape (n_samples,)
    new_time_axis : array, shape (n_samples,)
    smoothed_trials : array, shape (n_trials, n_samples)
    """
    conv_window, window_peak = smoothing_kernel(sfreq=int(sfreq), conv_width=conv_width)

    ms_data = ms_binary.astype(float)

    n_trials, n_samples = ms_data.shape
    smoothed_trials = np.full((n_trials, n_samples), np.nan)

    for trial_idx in range(n_trials):
        smoothed_trials[trial_idx, :] = lfilter(conv_window, 1, ms_data[trial_idx, :])

    mean_smoothed = np.nanmean(smoothed_trials, axis=0)
    sem_smoothed = np.nanstd(smoothed_trials, axis=0, ddof=1) / np.sqrt(np.sum(~np.isnan(smoothed_trials), axis=0))

    shift_window = window_peak / sfreq
    new_time_axis = time_axis - shift_window
    new_time_axis = np.ceil(new_time_axis * 1000) / 1000

    return mean_smoothed, sem_smoothed, new_time_axis, smoothed_trials

anech_uninter_mean, anech_uninter_sem, ms_time, anech_uninter_smoothed_trials = smooth_ms_trials(
    anech_uninter_binary, times_epoch, sfreq=sfreq, conv_width=50
)

anech_inter_mean, anech_inter_sem, _, anech_inter_smoothed_trials = smooth_ms_trials(
    anech_inter_binary, times_epoch, sfreq=sfreq, conv_width=50
)

reverb_uninter_mean, reverb_uninter_sem, _, reverb_uninter_smoothed_trials = smooth_ms_trials(
    reverb_uninter_binary, times_epoch, sfreq=sfreq, conv_width=50
)

reverb_inter_mean, reverb_inter_sem, _, reverb_inter_smoothed_trials = smooth_ms_trials(
    reverb_inter_binary, times_epoch, sfreq=sfreq, conv_width=50
)


# now let's plot the rate and see what she looks like !
fig, axes = plt.subplots(1, 2, figsize=(12, 5), sharey=True)

# Anechoic
axes[0].plot(ms_time, anech_uninter_mean, label='Uninter')
axes[0].fill_between(
    ms_time,
    anech_uninter_mean - anech_uninter_sem,
    anech_uninter_mean + anech_uninter_sem,
    alpha=0.3
)

axes[0].plot(ms_time, anech_inter_mean, label='Inter')
axes[0].fill_between(
    ms_time,
    anech_inter_mean - anech_inter_sem,
    anech_inter_mean + anech_inter_sem,
    alpha=0.3
)

axes[0].set_title('Anechoic')
axes[0].set_xlabel('Time (s)')
axes[0].set_ylabel('Microsaccade Rate (events/s)')
axes[0].legend()

# Reverb
axes[1].plot(ms_time, reverb_uninter_mean, label='Uninter')
axes[1].fill_between(
    ms_time,
    reverb_uninter_mean - reverb_uninter_sem,
    reverb_uninter_mean + reverb_uninter_sem,
    alpha=0.3
)

axes[1].plot(ms_time, reverb_inter_mean, label='Inter')
axes[1].fill_between(
    ms_time,
    reverb_inter_mean - reverb_inter_sem,
    reverb_inter_mean + reverb_inter_sem,
    alpha=0.3
)

axes[1].set_title('Reverb')
axes[1].set_xlabel('Time (s)')
axes[1].legend()

interrupt_time = 1.275

for ax in axes:
    ax.axvline(interrupt_time, linestyle='--')

plt.tight_layout()
plt.show()