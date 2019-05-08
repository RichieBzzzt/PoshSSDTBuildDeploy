using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.IO;
using System.Text;
using Microsoft.SqlServer.Server;
[Serializable]
[SqlUserDefinedAggregate(Format.UserDefined, MaxByteSize = -1)]
public struct ConcatMagic : IBinarySerialize
{
    private StringBuilder _accumulator;
    private string _delimiter;
    public Boolean IsNull { get; private set; }
    public void Init()
    {
        _accumulator = new StringBuilder();
        _delimiter = string.Empty;
        this.IsNull = true;
    }
    public void Accumulate(SqlString value, SqlString delimiter)
    {
        if (!delimiter.IsNull & delimiter.Value.Length > 0)
        {
            _delimiter = delimiter.Value;
            if (_accumulator.Length > 0)
            {
                _accumulator.Append(delimiter.Value);
            }
        }
        _accumulator.Append(value.Value);
        if (value.IsNull == false)
        {
            this.IsNull = false;
        }
    }
    public void Merge(ConcatMagic group)
    {
        if (_accumulator.Length > 0 & group._accumulator.Length > 0)
        {
            _accumulator.Append(_delimiter);
        }
        _accumulator.Append(group._accumulator.ToString());
    }
    public SqlString Terminate()
    {
        return new SqlString(_accumulator.ToString());
    }
    void IBinarySerialize.Read(System.IO.BinaryReader r)
    {
        _delimiter = r.ReadString();
        _accumulator = new StringBuilder(r.ReadString());
        if (_accumulator.Length != 0) this.IsNull = false;
    }
    void IBinarySerialize.Write(System.IO.BinaryWriter w)
    {
        w.Write(_delimiter);
        w.Write(_accumulator.ToString());
    }
}