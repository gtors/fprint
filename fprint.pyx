import logging
from fprint cimport *
from cpython cimport PyBytes_FromStringAndSize
from posix.types cimport suseconds_t, time_t
from posix.time cimport timeval

cdef class Driver:
    cdef fp_driver *ptr

    @staticmethod
    cdef new(fp_driver *ptr):
        d = Driver()
        d.ptr = ptr
        return d

    @property
    def name(self):
        if self.ptr != NULL:
            return <bytes> fp_driver_get_name(self.ptr)

    @property
    def full_name(self):
        if self.ptr != NULL:
            return <bytes> fp_driver_get_full_name(self.ptr)

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_driver_get_driver_id(self.ptr)

    @property
    def scan_type(self):
        if self.ptr != NULL:
            return fp_driver_get_scan_type(self.ptr)


cdef class DiscoveredPrints:
    cdef fp_dscv_print **prints
    cdef int number_prints

    def __cinit__(self):
        self.prints = fp_discover_prints()

        cdef int i = 0
        while self.prints[i] != NULL:
            i += 1
        self.number_prints = i

    def __dealloc__(self):
        fp_dscv_prints_free(self.prints)

    def __getitem__(self, int i):
        cdef fp_dscv_print *p
        if i < self.number_prints:
            p = self.prints[i]
            return DiscoveredPrint.new(p)

    def __len__(self):
        return self.number_prints


cdef class PrintData:
    cdef fp_print_data *ptr

    def __dealloc__(self):
        if self.ptr != NULL:
            fp_print_data_free(self.ptr)

    @staticmethod
    def load(Device d, fp_finger finger):
        pd = PrintData()
        if fp_print_data_load(d.ptr, finger, &pd.ptr) > 0:
            return pd

    @staticmethod
    def from_discovered_print(DiscoveredPrint p):
        pd = PrintData()
        if fp_print_data_from_dscv_print(p.ptr, &pd.ptr) > 0:
            return pd

    @staticmethod
    def from_data(bytes data):
        pd = PrintData()
        pd.ptr = fp_print_data_from_data(data, len(data))
        if pd.ptr != NULL:
            return pd

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_print_data_get_driver_id(self.ptr)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_print_data_get_devtype(self.ptr)

    @property
    def data(self):
        cdef unsigned char *buf
        cdef int buf_len
        if self.ptr != NULL:
            buf_len = fp_print_data_get_data(self.ptr, &buf)
            return PyBytes_FromStringAndSize(<char *>buf, buf_len)

    def save(self, fp_finger finger):
        if self.ptr != NULL:
            return fp_print_data_save(self.ptr, finger)

    def delete(self, Device d, fp_finger finger):
        if self.ptr != NULL:
            return fp_print_data_delete(d.ptr, finger)


cdef class DiscoveredPrint:
    cdef fp_dscv_print *ptr

    @staticmethod
    cdef new(fp_dscv_print *ptr):
        p = DiscoveredPrint()
        p.ptr = ptr
        return p

    @property
    def driver_id(self):
        if self.ptr != NULL:
            return fp_dscv_print_get_driver_id(self.ptr)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_dscv_print_get_devtype(self.ptr)

    def get_finger(self):
        if self.ptr != NULL:
            return fp_dscv_print_get_finger(self.ptr)

    def delete(self):
        if self.ptr != NULL:
            return fp_dscv_print_delete(self.ptr)


cdef class Minutia:
    cdef fp_minutia *ptr

    @staticmethod
    cdef new(fp_minutia *ptr):
        m = Minutia()
        m.ptr = ptr
        return m

    @property
    def x(self):
        if self.ptr != NULL:
            return self.ptr[0].x

    @property
    def y(self):
        if self.ptr != NULL:
            return self.ptr[0].y

    @property
    def ex(self):
        if self.ptr != NULL:
            return self.ptr[0].ex

    @property
    def ey(self):
        if self.ptr != NULL:
            return self.ptr[0].ey

    @property
    def direction(self):
        if self.ptr != NULL:
            return self.ptr[0].direction

    @property
    def reliability(self):
        if self.ptr != NULL:
            return self.ptr[0].reliability

    @property
    def type(self):
        if self.ptr != NULL:
            return self.ptr[0].type

    @property
    def appearing(self):
        if self.ptr != NULL:
            return self.ptr[0].appearing

    @property
    def feature_id(self):
        if self.ptr != NULL:
            return self.ptr[0].feature_id

    @property
    def nbrs(self):
        if self.ptr != NULL:
            return self.ptr[0].nbrs[0]

    @property
    def ridge_counts(self):
        if self.ptr != NULL:
            return self.ptr[0].ridge_counts[0]

    @property
    def num_nbrs(self):
        if self.ptr != NULL:
            return self.ptr[0].num_nbrs


cdef class Image:
    cdef fp_img *ptr

    @staticmethod
    cdef new(fp_img *ptr):
        i = Image()
        i.ptr = ptr
        return i

    def __dealloc__(self):
        if self.ptr != NULL:
            fp_img_free(self.ptr)

    @property
    def width(self):
        if self.ptr != NULL:
            return fp_img_get_width(self.ptr)

    @property
    def height(self):
        if self.ptr != NULL:
            return fp_img_get_height(self.ptr)

    @property
    def data(self):
        if self.ptr != NULL:
            return <bytes> fp_img_get_data(self.ptr)

    def save_to_file(self, str path):
        cdef bytes py_bytes = path.encode()
        cdef char* c_string = py_bytes
        if self.ptr != NULL:
            return fp_img_save_to_file(self.ptr, c_string)

    def standartize(self):
        if self.ptr != NULL:
            fp_img_standardize(self.ptr)

    def binarize(self):
        cdef fp_img *img
        if self.ptr != NULL:
            img = fp_img_binarize(self.ptr)
            if img != NULL:
                return Image.new(img)

    def get_minutiae(self):
        cdef int nr_minutiae = 0
        cdef fp_minutia **minutiae
        if self.ptr != NULL:
            minutiae = fp_img_get_minutiae(self.ptr, &nr_minutiae)
            if minutiae != NULL:
                return tuple(Minutia.new(minutiae[i]) for i in xrange(nr_minutiae))


cdef class DiscoveredDevices:
    cdef fp_dscv_dev **devices
    cdef int number_devices

    def __cinit__(self):
        self.devices = fp_discover_devs()

        cdef int i = 0
        while self.devices[i] != NULL:
            i += 1
        self.number_devices = i

    def __dealloc__(self):
        fp_dscv_devs_free(self.devices)

    def __getitem__(self, int i):
        cdef fp_dscv_dev *dd
        if i < self.number_devices:
            dd = self.devices[i]
            return DiscoverdDevice.new(dd)
        else:
            return None

    def __len__(self):
        return self.number_devices

    def dev_for_print_data(self, PrintData p):
        cdef fp_dscv_dev *dev = fp_dscv_dev_for_print_data(self.devices, p.ptr)
        if dev == NULL:
            return None
        else:
            return DiscoverdDevice.new(dev)

    def dev_for_dscv_print(self, DiscoveredPrint p):
        cdef fp_dscv_dev *dev = fp_dscv_dev_for_dscv_print(self.devices, p.ptr)
        if dev == NULL:
            return None
        else:
            return DiscoverdDevice.new(dev)


cdef class DiscoverdDevice:
    cdef fp_dscv_dev *ptr

    @staticmethod
    cdef new(fp_dscv_dev *ptr):
        dd = DiscoverdDevice()
        dd.ptr = ptr
        return dd

    @property
    def driver(self):
        cdef fp_driver *drv
        if self.ptr != NULL:
            drv = fp_dscv_dev_get_driver(self.ptr)
            if drv != NULL:
                return Driver.new(drv)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_dscv_dev_get_devtype(self.ptr)

    def supports_print_data(self, PrintData pd):
        if self.ptr != NULL:
            return <bint> fp_dscv_dev_supports_print_data(self.ptr, pd.ptr)

    def supports_dscv_print(self, DiscoveredPrint p):
        if self.ptr != NULL:
            return <bint> fp_dscv_dev_supports_dscv_print(self.ptr, p.ptr)


cdef class Device:
    cdef fp_dev *ptr

    @staticmethod
    cdef new(fp_dev *ptr):
        d = Device()
        d.ptr = ptr
        return d

    @staticmethod
    def open(DiscoverdDevice dd):
        cdef fp_dev *dev = fp_dev_open(dd.ptr)
        if dev != NULL:
            return Device.new(dev)

    def close(self):
        if self.ptr != NULL:
            fp_dev_close(self.ptr)

    @property
    def driver(self):
        cdef fp_driver *drv
        if self.ptr != NULL:
            drv = fp_dev_get_driver(self.ptr)
            if drv != NULL:
                return Driver.new(drv)

    @property
    def devtype(self):
        if self.ptr != NULL:
            return fp_dev_get_devtype(self.ptr)

    @property
    def number_enroll_stages(self):
        if self.ptr != NULL:
            return fp_dev_get_nr_enroll_stages(self.ptr)

    def supports_print_data(self, PrintData pd):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_print_data(self.ptr, pd.ptr)

    def supports_dscv_print(self, DiscoveredPrint p):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_dscv_print(self.ptr, p.ptr)

    def supports_imaging(self):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_imaging(self.ptr)

    def supports_identification(self):
        if self.ptr != NULL:
            return <bint> fp_dev_supports_identification(self.ptr)

    def capture_image(self, int unconditional):
        if self.ptr != NULL:
            i = Image()
            fp_dev_img_capture(self.ptr, unconditional, &i.ptr)
            return i

    def image_width(self):
        if self.ptr != NULL:
            return fp_dev_get_img_width(self.ptr)

    def image_height(self):
        if self.ptr != NULL:
            return fp_dev_get_img_height(self.ptr)

    def enroll_finger(self):
        if self.ptr != NULL:
            pd = PrintData()
            i = Image()
            r = FP_ENROLL_RETRY
            while r != FP_ENROLL_COMPLETE:
                r = fp_enroll_finger_img(self.ptr, &pd.ptr, &i.ptr)
                if r < 0:
                    raise RuntimeError("Internal I/O error while enrolling: %i" % r)
                if r == FP_ENROLL_COMPLETE:
                    logging.debug("enroll complete")
                if r == FP_ENROLL_FAIL:
                    print("Failed. Enrollment process reset.")
                    return None, i
                if r == FP_ENROLL_PASS:
                    logging.debug("enroll PASS")
                    pass
                if r == FP_ENROLL_RETRY:
                    logging.debug("enroll RETRY")
                    pass
                if r == FP_ENROLL_RETRY_TOO_SHORT:
                    logging.debug("enroll RETRY_SHORT")
                    pass
                if r == FP_ENROLL_RETRY_CENTER_FINGER:
                    logging.debug("enroll RETRY_CENTER")
                    pass
                if r == FP_ENROLL_RETRY_REMOVE_FINGER:
                    logging.debug("enroll RETRY_REMOVE")
                    pass
            return (pd, i)

    def verify_finger(self, PrintData pd):
        if self.ptr != NULL:
            i = Image()
            while True:
                r = fp_verify_finger_img(self.ptr, pd.ptr, &i.ptr)
                if r < 0:
                    raise RuntimeError("verify error: %i" % r)
                if r == FP_VERIFY_NO_MATCH:
                    return False, i
                if r == FP_VERIFY_MATCH:
                    return True, i
                if r == FP_VERIFY_RETRY:
                    pass
                if r == FP_VERIFY_RETRY_TOO_SHORT:
                    pass
                if r == FP_VERIFY_RETRY_CENTER_FINGER:
                    pass
                if r == FP_VERIFY_RETRY_REMOVE_FINGER:
                    pass

    def identify_finger(self):
        cdef size_t match_offset = 0
        if self.ptr != NULL:
            pd = PrintData()
            i = Image()
            fp_identify_finger_img(self.ptr, &pd.ptr, &match_offset, &i.ptr)
            return (pd, match_offset, i)


#cdef class Poll:
#    cdef fp_pollfd *ptr
#
#
#def handle_events_timeout(time_t sec, suseconds_t usec):
#    cdef timeval tv = timeval(sec=sec, usec=usec)
#    return fp_handle_events_timeout(&tv)
#
#def handle_events():
#    fp_handle_events()
#
#def get_next_timeout():
#    cdef timeval tv
#    ret = fp_get_next_timeout(&tv)
#    return (tv, ret)
#
#
def init():
    if fp_init() < 0:
        raise RuntimeError("Failed to init libfprint")

def exit():
    fp_exit()

def set_debug(int level):
    fp_set_debug(level)
