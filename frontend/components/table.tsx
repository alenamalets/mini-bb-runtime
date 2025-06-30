type Props = {
  columns: string[];
  data: Record<string, any>[];
};

export default function Table({ data, columns }: Props) {
  if (data.length === 0)
    return <p className="text-gray-500 italic">No data available.</p>;

  return (
    <div className="w-full sm:w-1/2 overflow-x-auto rounded-xl border border-gray-200 shadow-sm">
      <table className="min-w-full divide-y divide-gray-200 text-sm">
        <thead className="bg-gray-800">
          <tr>
            {columns.map((col) => (
              <th
                key={col}
                className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-white"
              >
                {col}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, idx) => (
            <tr
              key={idx}
              className="hover:bg-gray-100 transition-colors duration-150"
            >
              {columns.map((col) => (
                <td
                  key={col}
                  className="px-6 py-4 whitespace-nowrap text-gray-700"
                >
                  {row[col]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
