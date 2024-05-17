namespace YolusCORE.Extensions
{
	public static class IEnumerableExtensions
	{
		private static readonly Random _rnd = new();

		public static void Shuffle<T>(this IList<T> list)
		{
			for (var i = 0; i < list.Count; i++)
				list.Swap(i, _rnd.Next(i, list.Count));
		}

		public static void Swap<T>(this IList<T> list, int i, int j)
		{
			(list[j], list[i]) = (list[i], list[j]);
		}

		public static T Random<T>(this IList<T> list) =>
			list[_rnd.Next(0, list.Count)];
	}
}