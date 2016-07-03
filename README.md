THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

kitphysikpool-logout.sh
=======================

This script allows people who forgot to log out of one of the shared computers
of the [KIT's physics department](http://comp.physik.kit.edu/) to automatically
check the computers one by one via SSH and log out if it is found they are
still logged in.


Usage
-----

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