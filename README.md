THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

kitphysikpool-logout.sh
=======================

This script allows people to automatically identify shared computers of the
[KIT physics department pool](http://comp.physik.kit.edu/) ("Poolraum-PCs")
where they are still logged in and log out of them via SSH.


Usage
-----

The script *has* to be run from another shared KIT physics department computer
("Poolraum-PC"), so log into one of those first (either via SSH or physically)
and run the instructions on this computer only. Simply being inside the KIT
network is not enough, it has to be run from one of those computers. There are
ways around this requirement, but it's probably not worth the effort.

Download the latest version of the script from Github:

````bash
wget -nc https://raw.githubusercontent.com/smheidrich/kitphysikpool-logout/master/kitphysikpool-logout.sh
````

If you want a package that comes with this README as well as other development
files, you can also download the latest official release from the
[Releases](https://github.com/smheidrich/kitphysikpool-logout/releases/) page
on Github or better yet clone the git repository (see "Contributing" below).

Make it executable:

````bash
chmod +x kitphysikpool-logout.sh
````

Open it in an editor to review what it does and read the "Remarks" below. You
can then run it via:

````bash
./kitphysikpool-logout.sh
````

Remarks
-------

What the "logout" actually does is simply kill every single process that was
spawned by your user account on the remote machine. So obviously, if you have
any important unsaved work on the other machine that hasn't been transferred
over to the machine you're currently on, you shouldn't use this script (this
would also be true if the logout happened by any other means, by the way). One
reason the "logout" kills everything and not just your KDE session is that this
allows it to catch processes that were started from a virtual console
(``Ctrl``+``Alt``+Function key) or decoupled from the session in some manner
(e.g. ``nohup``).

The hostnames of the computers that the script should connect to as well as
some other details can be changed by modifying the first few lines of the
script. They are pretty self-explanatory and you normally won't need to change
anything because they should work out of the box inside the KIT physics dept.
pool.

The exact behaviour of the script differs depending on your SSH setup:

- If you have set up an SSH key, put it into ``~/.ssh/authorized_keys`` and
  loaded it into ``ssh-agent``, the script will simply use this key to connect
  to every configured computer.
- If you do not have an SSH key set up, the script will by default attempt to
  generate one for you. Because your home directory is on a shared network
  filesystem, this key will be instantly synced to all the other computers and
  hence the script can use it to connect to them. After the script is done or
  if it is aborted for any other reason, it will delete the key again so
  everything is back to normal.

If for any reason you do not want the script to automatically generate a
temporary SSH key, you can disable this feature by running the script with the
``-k`` option:

````bash
./kitphysikpool-logout.sh -k
````

In this case, the script will simply fail if it can't connect using a key
loaded into ``ssh-agent``.

Contributing
------------

You can report bugs, request features and contribute code at the script's
[**Github repository**](https://github.com/smheidrich/kitphysikpool-logout).
