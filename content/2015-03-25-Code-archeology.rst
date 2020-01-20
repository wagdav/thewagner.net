Code archeology
===============
:summary: Found some code I wrote back in 2004.  The goal was to control the movement of a telescope, but I ended up fighting with fork and select.

Back in 2004 a friend of mine was building a telescope and I wanted it to have
an automated control system, where the user can select a star she
wants to see and the system would automatically orient the telescope towards the
appropriate celestial coordinates.  I called this ambitious plan: "Project Starfinder".  The plan was that he builds the telescope and I write the software.  We both did our job separately, but we never got around to put our works together.

Though Project Starfinder failed, the motor controller I built was quite a success.  The other day I was browsing through my old backups and I stumbled upon the code I wrote 11 years ago.  ``motorc`` and ``motord`` were the client and the server component, respectively, of my stepper motor controller.

Daemon
------

The ``motord`` daemon was responsible to receive messages from the connected clients and translate them to instructions to be written to the parallel port.  I also built a circuit that could drive four motors connected to the PCs parallel port.  The daemon needed to run with root privileges.

The daemon was accepting connections on a PF_LOCAL socket.  For each incoming connection the daemon forked off a child process to handle the one to one communication with the connected client.  I had read somewhere that Apache worked this way and I remember being quiet very to learn about ``fork()``.

I used ``select`` on an ``fd_set`` to process the incoming messages.  This caused me a lot of headaches.  I didn't really understand what was going on with these file descriptors.  Everything about them seemed magical.  I probably copied the respective code from a tutorial or somewhere.

Anyhow, the messages arrived from the socket and they were processed in a large switch-case:

.. code-block:: c

    pid = fork (); /* forking off */
    
    if (pid == 0) /* if we are a child process */
    {  
       select (FD_SETSIZE, &set, NULL, NULL, &timeout);
       while (1)
       {
          read (client, data, sizeof(t_motor_command));
          if (debug)
             syslog (LOG_DAEMON | LOG_DEBUG,
                     "Instruction: 0x%x, Address: 0x%x",
                     data->inst,
                     data->addr);

          if (data->inst == BYE)
             break; /* TODO: a safer solution needed */

          switch (data->inst)
          {
             case MOTOREN: /* Motor enable */
                 motors[data->addr]->enabled = 1;
                 break;
             case MOTORDIS: /* Motor disable */ 
                 motors[data->addr]->enabled = 0;
                 break;
             case MOTORR: /* Direction right */
                 motors[data->addr]->direction = 1;
                 break;
             case MOTORL: /* Direction left */
                 motors[data->addr]->direction = 0;
                 break;
             case MOTORCLR:	/* clear the position */
                 motors[data->addr]->position = 0;
                 break;
             /* ... */
           }
        }
    }

This is the code from the source file almost literally.  I used 8 spaces for indentation and apparently I didn't care about lines longer than 80 characters back then.

I developed a simple binary protocol to communicate over the socket.  The commands were represented by ``t_motor_command`` data structure:

.. code-block:: c

   typedef struct
   {
        WORD inst;  /* instruction byte*/
        WORD addr;  /* motor address   */
   } t_motor_command;

Pretty standard stuff.

The motor daemon also had the following features:

* read and parsed a configuration file

* supported arbitrary numbers of motors. In fact the motor objects were stored in a linked list.

* wrote log messages to the syslog

* changes in the motor position were made available to all clients 

* handled SIGTERM and SIGCHILD signals and made a clean exit

* it was GPL licensed

I didn't know how to use ``valgrind`` or ``gdb`` back then, so probably it leaked memory :-).


Graphical client
----------------

My memories about development of the client application are more vague: it was much faster to develop it, and also it is much simpler program than the daemon.  I used Glade to design a GTK interface (with GTK 1.2).  I tried to compile the project in order to make some screenshots of the interface, but I failed.  The project depends on old libraries, moreover the newer version of Glade is having troubles reading the old interface files.

Anyway the interface was quite simple: it had four knobs for the four motors.  As the user turned the knobs the motors turned.  Very exciting!  If you opened multiple clients the knobs were synchronized (there was no position feedback from the motors).

Summary
-------

Reading through the code brought back some nice memories about this project.  I had great fun designing the client-server architecture and I was really proud that I could handle multiple clients by forking off the server process.  It's a pity though that the code didn't move any telescopes...
