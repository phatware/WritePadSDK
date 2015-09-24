/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                           * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this 
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL PHATWARE CORP.  
 * BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL, 
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER, 
 * INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS 
 * OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT PHATWARE CORP.
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in EULA and in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is PhatWare Corp.
 * 530 Showers Drive Suite 7 #333 Mountain View, CA 94040
 *
 * ************************************************************************************* */

using System;
using System.Collections.Generic;
using System.Linq;
using Windows.Foundation.Collections;

namespace WritePad_CSharpSample.Common
{
    /// <summary>
    /// Implementation of IObservableMap that supports reentrancy for use as a default view
    /// model.
    /// </summary>
    public class ObservableDictionary : IObservableMap<string, object>
    {
        private class ObservableDictionaryChangedEventArgs : IMapChangedEventArgs<string>
        {
            public ObservableDictionaryChangedEventArgs(CollectionChange change, string key)
            {
                this.CollectionChange = change;
                this.Key = key;
            }

            public CollectionChange CollectionChange { get; private set; }
            public string Key { get; private set; }
        }

        private Dictionary<string, object> _dictionary = new Dictionary<string, object>();
        public event MapChangedEventHandler<string, object> MapChanged;

        private void InvokeMapChanged(CollectionChange change, string key)
        {
            var eventHandler = MapChanged;
            if (eventHandler != null)
            {
                eventHandler(this, new ObservableDictionaryChangedEventArgs(change, key));
            }
        }

        public void Add(string key, object value)
        {
            this._dictionary.Add(key, value);
            this.InvokeMapChanged(CollectionChange.ItemInserted, key);
        }

        public void Add(KeyValuePair<string, object> item)
        {
            this.Add(item.Key, item.Value);
        }

        public bool Remove(string key)
        {
            if (this._dictionary.Remove(key))
            {
                this.InvokeMapChanged(CollectionChange.ItemRemoved, key);
                return true;
            }
            return false;
        }

        public bool Remove(KeyValuePair<string, object> item)
        {
            object currentValue;
            if (this._dictionary.TryGetValue(item.Key, out currentValue) &&
                Object.Equals(item.Value, currentValue) && this._dictionary.Remove(item.Key))
            {
                this.InvokeMapChanged(CollectionChange.ItemRemoved, item.Key);
                return true;
            }
            return false;
        }

        public object this[string key]
        {
            get
            {
                return this._dictionary[key];
            }
            set
            {
                this._dictionary[key] = value;
                this.InvokeMapChanged(CollectionChange.ItemChanged, key);
            }
        }

        public void Clear()
        {
            var priorKeys = this._dictionary.Keys.ToArray();
            this._dictionary.Clear();
            foreach (var key in priorKeys)
            {
                this.InvokeMapChanged(CollectionChange.ItemRemoved, key);
            }
        }

        public ICollection<string> Keys
        {
            get { return this._dictionary.Keys; }
        }

        public bool ContainsKey(string key)
        {
            return this._dictionary.ContainsKey(key);
        }

        public bool TryGetValue(string key, out object value)
        {
            return this._dictionary.TryGetValue(key, out value);
        }

        public ICollection<object> Values
        {
            get { return this._dictionary.Values; }
        }

        public bool Contains(KeyValuePair<string, object> item)
        {
            return this._dictionary.Contains(item);
        }

        public int Count
        {
            get { return this._dictionary.Count; }
        }

        public bool IsReadOnly
        {
            get { return false; }
        }

        public IEnumerator<KeyValuePair<string, object>> GetEnumerator()
        {
            return this._dictionary.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return this._dictionary.GetEnumerator();
        }

        public void CopyTo(KeyValuePair<string, object>[] array, int arrayIndex)
        {
            int arraySize = array.Length;
            foreach (var pair in this._dictionary)
            {
                if (arrayIndex >= arraySize) break;
                array[arrayIndex++] = pair;
            }
        }
    }
}
