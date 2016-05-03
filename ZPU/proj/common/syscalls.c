#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>

#include "papilio_zpu.h"

extern int	inbyte(void);
extern void	outbyte(int c);

void __attribute__ ((weak)) 
_zpu_interrupt(void)  
{
	/* not implemented in libgloss */
	__asm("breakpoint");
	while (1);
}


/*
 * write  -- write bytes to the serial port. Ignore fd, since
 *          we only have stdout.
 */
int
_DEFUN (write, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	{
	  int i;
		
	  for (i = 0; i < nbytes; i++) {
	    if (*(buf + i) == '\n') {
	      outbyte ('\r');
	    }
	    outbyte (*(buf + i));
	  }
	  return (nbytes);
	}
}


/*
 * read  -- read bytes from the serial port. Ignore fd, since
 *          we only have stdin.
 */
int
_DEFUN (read, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	{
	  int i = 0;
	
	  for (i = 0; i < nbytes; i++) {
		char t=inbyte();

		if ((t!='\r')&&(t!='\n'))
		{
		    *(buf + i) = t;
		    outbyte(t); // echo
		} else
		{
	    	// terminate the line in the way expected by the libraries
		    *(buf + i) = '\n';
	    	i++;
		    outbyte('\r');
		    outbyte('\n');
	      break;
	    }
	  }
	  return (i);
	}
}


/*
 * open -- open a file descriptor. We don't have a filesystem, so
 *         we return an error.
 */
int
open(const char *buf,
       int flags,
       int mode,
       ...)  
{
	{
	  errno = EIO;
	  return (-1);
	}
}

/*
 * close -- We don't need to do anything, but pretend we did.
 */
int
_DEFUN (close ,(fd),
       int fd)  
{
  return (0);
}


int __attribute__ ((weak))
ftruncate (int file, off_t length)  
{
	return -1;
}

/*
 * unlink -- since we have no file system, 
 *           we just return an error.
 */
int
_DEFUN (unlink, (path),
        char * path)  
{
	errno = EIO;
	return (-1);
}


/*
 * lseek --  Since a serial port is non-seekable, we return an error.
 */
off_t
_DEFUN (lseek, (fd,  offset, whence),
       int fd _AND
       off_t offset _AND
       int whence)  
{
	errno = ESPIPE;
	return ((off_t)-1);
}

int
_DEFUN (fstat, (fd, buf),
       int fd _AND
       struct stat *buf)  
{
	{
/*
 * fstat -- Since we have no file system, we just return an error.
 */
	  buf->st_mode = S_IFCHR;	/* Always pretend to be a tty */
	  buf->st_blksize = 0;

	  return (0);
	}
}


int
_DEFUN (stat, (path, buf),
       const char *path _AND
       struct stat *buf)  
{
	errno = EIO;
	return (-1);
}



int
_DEFUN (isatty, (fd),
       int fd)  
{
	return (1);
}
