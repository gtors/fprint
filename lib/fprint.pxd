# cython: language_level=3

from posix.time cimport timeval
from libc.stdint cimport uint32_t, uint16_t


cdef extern from "glib-2.0/glib.h":
    ctypedef void *gpointer
    ctypedef void *gconstpointer
    ctypedef int gint
    ctypedef unsigned int guint
    ctypedef unsigned long gulong
    ctypedef signed long long gint64
    ctypedef unsigned long long guint64
    ctypedef gint gboolean
    ctypedef double gdouble

    ctypedef unsigned int gsize
    ctypedef signed int gssize
    ctypedef char gchar
    ctypedef unsigned char guchar
    ctypedef int GQuark


    ctypedef struct GObject:
        pass

    ctypedef struct GMainContext:
        pass

    ctypedef struct GSList:
        gpointer data
        GSList *next

    ctypedef struct GList:
        gpointer data
        GList *next
        GList *prev

    ctypedef struct GPtrArray:
        gpointer *pdata
        guint len

    ctypedef struct GError:
        GQuark domain
        gint code
        gchar *message


    ctypedef struct GCancellable:
        pass

    ctypedef struct GDate:
        pass

    ctypedef struct GType:
        pass

    ctypedef struct GAsyncResult:
        pass

    gpointer g_ptr_array_index(GPtrArray, gint)

    ctypedef void (*GCallback) ()
    ctypedef void (*GDestroyNotify) (gpointer)
    ctypedef gboolean (*GSourceFunc) (gpointer data)
    ctypedef void (*GAsyncReadyCallback) (
        GObject *source_object,
        GAsyncResult *res,
        gpointer user_data)


cdef extern from "libfprint-2/fprint.h":

    ctypedef struct FpDevice:
        pass
    
    ctypedef struct FpContext:
        pass

    ctypedef struct FpPrint:
        pass

    ctypedef struct FpImageDevice:
        pass

    ctypedef struct FpImage:
        pass

    ctypedef void FpMinutia

    cpdef enum FpDeviceType:
        # The device is virtual device
        FP_DEVICE_TYPE_VIRTUAL = 0
        # The device is a USB device
        FP_DEVICE_TYPE_USB

    ctypedef enum FpDeviceRetry:
        # Error codes representing scan failures resulting in the user needing to
        # retry.


        # The scan did not succeed due to poor scan quality
        # or other general user scanning problem.
        FP_DEVICE_RETRY_GENERAL = 0

        # The scan did not succeed because the finger
        # swipe was too short.
        FP_DEVICE_RETRY_TOO_SHORT

        # The scan did not succeed because the finger
        # was not centered on the scanner.
        FP_DEVICE_RETRY_CENTER_FINGER

        # The scan did not succeed due to quality or pressure problems
        # the user should remove their finger from the scanner before 
        # retrying.
        FP_DEVICE_RETRY_REMOVE_FINGER

    ctypedef enum FpDeviceError:
        # Error codes for device operations. More specific errors from other domains
        # such as #G_IO_ERROR or #G_USB_DEVICE_ERROR may also be reported.

        # A general error occured.
        FP_DEVICE_ERROR_GENERAL
        # The device does not support the requested operation.
        FP_DEVICE_ERROR_NOT_SUPPORTED
        # The device needs to be opened to start this operation.
        FP_DEVICE_ERROR_NOT_OPEN
        # The device has already been opened.
        FP_DEVICE_ERROR_ALREADY_OPEN
        # The device is busy with another request.
        FP_DEVICE_ERROR_BUSY
        # Protocol error
        FP_DEVICE_ERROR_PROTO
        # The passed data is invalid
        FP_DEVICE_ERROR_DATA_INVALID
        # Requested print was not found on device
        FP_DEVICE_ERROR_DATA_NOT_FOUND
        # No space on device available for operation
        FP_DEVICE_ERROR_DATA_FULL

    ctypedef enum FpScanType:
        # Sensor requires swiping the finger.
        FP_SCAN_TYPE_SWIPE = 0
        # Sensor requires placing/pressing down the finger.
        FP_SCAN_TYPE_PRESS

    ctypedef enum FpFinger:
        # The finger is unknown
        FP_FINGER_UNKNOWN
        # Left thumb
        FP_FINGER_LEFT_THUMB
        # Left index finger
        FP_FINGER_LEFT_INDEX
        # Left middle finger
        FP_FINGER_LEFT_MIDDLE
        # Left ring finger
        FP_FINGER_LEFT_RING
        # Left little finger
        FP_FINGER_LEFT_LITTLE
        # Right thumb
        FP_FINGER_RIGHT_THUMB
        # Right index finger
        FP_FINGER_RIGHT_INDEX
        # Right middle finger
        FP_FINGER_RIGHT_MIDDLE
        # Right ring finger
        FP_FINGER_RIGHT_RING
        # Right little finger
        FP_FINGER_RIGHT_LITTLE
        # The first finger in the fp-print order
        FP_FINGER_FIRST
        # The last finger in the fp-print order
        FP_FINGER_LAST

    ctypedef void (*FpEnrollProgress)(
        FpDevice *device,
        # Number eof completed stage
        gint completed_stages,
        # The last scanned print
        FpPrint *_print,
        # User provided data.
        gpointer user_data,
        # The error is guaranteed to be of type FP_DEVICE_RETRY if set
        GError *error)


    # Report the result of a match(identify or verify) operation.
    #
    # If @match is non-%NULL, then it is set to the matching #FpPrint as passed
    # to the match operation. In this case @error will always be %NULL.
    #
    # If @error is not %NULL then its domain is guaranteed to be
    # %FP_DEVICE_RETRY. All other error conditions will not be reported using
    # this callback. If such an error occurs before a match/no-match decision
    # can be made, then this callback will not be called. Should an error
    # happen afterwards, then you will get a match report through this callback
    # and an error when the operation finishes.
    #
    # If @match and @error are %NULL, then a finger was presented but it did not
    # match any known print.
    #
    # @print represents the newly scanned print. The driver may or may not
    # provide this information. Image based devices will provide it and it
    # allows access to the raw data.
    #
    # This callback exists because it makes sense for drivers to wait e.g. on
    # finger removal before completing the match operation. However, the
    # success/failure can often be reported at an earlier time, and there is
    # no need to make the user wait.

    ctypedef void (*FpMatchCb)(
        FpDevice *device,
        # The matching print if any matched @print
        FpPrint *match,
        # The newly scanned print
        FpPrint *_print,
        # User provided data
        gpointer user_data,
        GError *error)
    
    # Image
    FpImage *fp_image_new (gint width, gint height)
    guint fp_image_get_width (FpImage *self)
    guint fp_image_get_height (FpImage *self)
    gdouble fp_image_get_ppmm (FpImage *self)
    const guchar * fp_image_get_data (FpImage *self, gsize *len)
    const guchar * fp_image_get_binarized (FpImage *self, gsize *len)
    void fp_minutia_get_coords (FpMinutia *min, gint *x, gint *y)
    GPtrArray * fp_image_get_minutiae (FpImage *self)
    void fp_image_detect_minutiae (
        FpImage *self,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)
    gboolean fp_image_detect_minutiae_finish (
        FpImage *self,
        GAsyncResult *result,
        GError **error)

    # Image device
    FpImageDevice *fp_image_device_new()

    # Print
    FpPrint *fp_print_new(FpDevice *device)
    FpPrint *fp_print_new_from_data(guchar *data, gsize length)
    gboolean fp_print_to_data(guchar **data, gsize length)
    const gchar *fp_print_get_driver(FpPrint *_print)
    const gchar *fp_print_get_device_id(FpPrint *_print)
    FpImage *fp_print_get_image(FpPrint *_print)
    FpFinger fp_print_get_finger(FpPrint *_print)
    const gchar *fp_print_get_username(FpPrint *_print)
    const gchar *fp_print_get_description(FpPrint *_print)
    const GDate *fp_print_get_enroll_date(FpPrint *_print)
    gboolean fp_print_get_device_stored(FpPrint *_print)
    void fp_print_set_finger(FpPrint *_print, FpFinger finger)
    void fp_print_set_username(FpPrint *_print, const gchar *username)
    void fp_print_set_description(FpPrint *_print, const gchar *description)
    void fp_print_set_enroll_date(FpPrint *_print, const GDate *enroll_date)
    gboolean fp_print_compatible(FpPrint *self, FpDevice *device)
    gboolean fp_print_equal(FpPrint *self, FpPrint *other)
    gboolean fp_print_serialize(
        FpPrint *_print,
        guchar **data, 
        gsize *length, 
        GError **error)
    FpPrint *fp_print_deserialize(
        const guchar *data, 
        gsize length, 
        GError **error)

    # Device
    FpDevice *fp_device_new()
    const gchar *fp_device_get_driver(FpDevice *device)
    const gchar *fp_device_get_device_id(FpDevice *device)
    const gchar *fp_device_get_name(FpDevice *device)
    gboolean fp_device_is_open(FpDevice *device)
    FpScanType fp_device_get_scan_type(FpDevice *device)
    gint fp_device_get_nr_enroll_stages(FpDevice *device)
    gboolean fp_device_supports_identify(FpDevice *device)
    gboolean fp_device_supports_capture(FpDevice *device)
    gboolean fp_device_has_storage(FpDevice *device)

    # Context
    FpContext *fp_context_new()
    void fp_context_enumerate(FpContext *context)
    GPtrArray *fp_context_get_devices(FpContext *context)
    GQuark fp_device_retry_quark()
    GQuark fp_device_error_quark()
    GType fp_device_type_get_type()
    GType fp_scan_type_get_type()
    GType fp_device_retry_get_type()
    GType fp_device_error_get_type()
    GType fp_finger_get_type()

    # Openning device
    void fp_device_open(
        FpDevice *device,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_close(
        FpDevice *device,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_enroll(
        FpDevice *device,
        FpPrint *template_print,
        GCancellable *cancellable,
        FpEnrollProgress progress_cb,
        gpointer progress_data,
        GDestroyNotify progress_destroy,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_verify(
        FpDevice *device,
        FpPrint *enrolled_print,
        GCancellable *cancellable,
        FpMatchCb match_cb,
        gpointer match_data,
        GDestroyNotify match_destroy,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_identify(
        FpDevice *device,
        GPtrArray *prints,
        GCancellable *cancellable,
        FpMatchCb match_cb,
        gpointer match_data,
        GDestroyNotify match_destroy,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_capture(
        FpDevice *device,
        gboolean wait_for_finger,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_delete_print(
        FpDevice *device,
        FpPrint *enrolled_print,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)

    void fp_device_list_prints(
        FpDevice *device,
        GCancellable *cancellable,
        GAsyncReadyCallback callback,
        gpointer user_data)

    gboolean fp_device_open_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    gboolean fp_device_close_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    FpPrint *fp_device_enroll_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    gboolean fp_device_verify_finish(
        FpDevice *device,
        GAsyncResult *result,
        gboolean *match,
        FpPrint **_print,
        GError **error)

    gboolean fp_device_identify_finish(
        FpDevice *device,
        GAsyncResult *result,
        FpPrint **match,
        FpPrint **_print,
        GError **error)

    FpImage * fp_device_capture_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    gboolean fp_device_delete_print_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    GPtrArray * fp_device_list_prints_finish(
        FpDevice *device,
        GAsyncResult *result,
        GError **error)

    gboolean fp_device_open_sync(
        FpDevice *device,
        GCancellable *cancellable,
        GError **error)

    gboolean fp_device_close_sync(
        FpDevice *device,
        GCancellable *cancellable,
        GError **error)

    FpPrint * fp_device_enroll_sync(
        FpDevice *device,
        FpPrint *template_print,
        GCancellable *cancellable,
        FpEnrollProgress progress_cb,
        gpointer progress_data,
        GError **error)

    gboolean fp_device_verify_sync(
        FpDevice *device,
        FpPrint *enrolled_print,
        GCancellable *cancellable,
        FpMatchCb match_cb,
        gpointer match_data,
        gboolean *match,
        FpPrint **_print,
        GError **error)

    gboolean fp_device_identify_sync(
        FpDevice *device,
        GPtrArray *prints,
        GCancellable *cancellable,
        FpMatchCb match_cb,
        gpointer match_data,
        FpPrint **match,
        FpPrint **_print,
        GError **error)

    FpImage * fp_device_capture_sync(
        FpDevice *device,
        gboolean wait_for_finger,
        GCancellable *cancellable,
        GError **error)

    gboolean fp_device_delete_print_sync(
        FpDevice *device,
        FpPrint *enrolled_print,
        GCancellable *cancellable,
        GError **error)

    GPtrArray * fp_device_list_prints_sync(
        FpDevice *device,
        GCancellable *cancellable,
        GError **error)

